import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' show MultipartFile;
import 'package:petrov_hockey_academy_flutter/media/media.dart';
import 'package:petrov_hockey_academy_flutter/repositories/media_repository.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

part 'media_event.dart';
part 'media_state.dart';

/// Блок для взаимодействия пользователя с его собственными медиа(альбомы/видео):
/// Просмотр, Добавление.
///
/// [MediaBloc] имеет зависимость от [AuthenticationRepository] для отправки запросов,
/// требующих токен пользователя.
class MediaBloc extends Bloc<MediaEvent, MediaState> {
  MediaBloc({required AuthenticationRepository authenticationRepository})
      : super(const MediaState()) {
    on<MediaFetched>(_onMediaFetched);
    on<MediaAlbumLoadedMore>(_onAlbumLoadedMore, transformer: droppable());
    on<MediaVideoLoadedMore>(_onVideoLoadedMore, transformer: droppable());
    on<MediaImagesPicked>(_onImagesPicked);
    on<MediaAlbumSubmitted>(_onAlbumSubmitted);
    on<MediaVideoSubmitted>(_onVideoSubmitted);
    on<MediaSelectedGroupChanged>(_onSelectedGroupChanged);
    on<AddMediaSettedInitialState>(_onSetInitialState);
    on<MediaVideoTitleInputChanged>(_onVideoTitleInputChanged);
    on<MediaAlbumTitleInputChanged>(_onAlbumTitleInputChanged);
    on<MediaUrlInputChanged>(_onUrlInputChanged);
  }

  final getIt = GetIt.instance;

  final _mediaRepository = MediaRepository();

  Duration throttleDuration = const Duration(milliseconds: 100);

  /// Валидация введенного url добавляемого видео + названия видео.
  ///
  /// Вызывается на каждое изменение в поле ввода url.
  void _onUrlInputChanged(
    MediaUrlInputChanged event,
    Emitter<MediaState> emit,
  ) {
    final inputUrl = InputUrl.dirty(event.inputUrl);

    return emit(
      state.copyWith(
        inputUrl: inputUrl,
        formzStatus: Formz.validate([inputUrl, state.inputVideoTitle]),
      ),
    );
  }

  /// Валидация введенного названия видео + url видео.
  ///
  /// Вызывается на каждое изменение в поле ввода url.
  void _onVideoTitleInputChanged(
    MediaVideoTitleInputChanged event,
    Emitter<MediaState> emit,
  ) {
    final inputTitle = InputVideoTitle.dirty(event.inputTitle);

    return emit(
      state.copyWith(
        inputVideoTitle: inputTitle,
        formzStatus: Formz.validate([inputTitle, state.inputUrl]),
      ),
    );
  }

  /// Валидация введенного названия альбома.
  ///
  /// Вызывается на каждое изменение в поле ввода названия альбома.
  void _onAlbumTitleInputChanged(
    MediaAlbumTitleInputChanged event,
    Emitter<MediaState> emit,
  ) {
    final inputTitle = InputAlbumTitle.dirty(event.inputTitle);

    return emit(
      state.copyWith(
        inputAlbumTitle: inputTitle,
        formzStatus: Formz.validate([inputTitle]),
      ),
    );
  }

  /// Возвращает стейт к значению по умолчанию.
  ///
  /// Вызывается когда закрывается экран добавления фото/видео.
  void _onSetInitialState(
    AddMediaSettedInitialState event,
    Emitter<MediaState> emit,
  ) {
    return emit(
      state.copyWith(
        inputAlbumTitle: const InputAlbumTitle.pure(),
        inputVideoTitle: const InputVideoTitle.pure(),
        inputUrl: const InputUrl.pure(),
        formzStatus: FormzStatus.pure,
        selectedGroupId: event.groupId,
        images: [],
      ),
    );
  }

  /// Изменение выбранной группы при создании альбома/видео
  void _onSelectedGroupChanged(
    MediaSelectedGroupChanged event,
    Emitter<MediaState> emit,
  ) {
    return emit(
      state.copyWith(
        selectedGroupId: event.groupId,
      ),
    );
  }

  /// Отправляется мутация на создание видео к API.
  ///
  /// Вызыватся на нажатие кнопки "Создать" видео.
  Future<void> _onVideoSubmitted(
    MediaVideoSubmitted event,
    Emitter<MediaState> emit,
  ) async {
    emit(state.copyWith(formzStatus: FormzStatus.submissionInProgress));

    try {
      final response = await _mediaRepository.addVideo(
        title: state.inputVideoTitle.value,
        author: event.author,
        groupId: state.selectedGroupId,
        url: state.inputUrl.value,
      );

      // Проверка на ошибку
      if (response == false || response == null) {
        throw Exception();
      } else {
        // Ставлю MediaStatus.initial для загрузки списка медиа заново
        return emit(
          state.copyWith(
            status: MediaStatus.initial,
            albumsPage: 0,
            videosPage: 0,
            formzStatus: FormzStatus.submissionSuccess,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(formzStatus: FormzStatus.submissionFailure));
    }
  }

  /// Отправляется мутация на создание альбома к API.
  ///
  /// Вызыватся на нажатие кнопки "Создать" альбом.
  Future<void> _onAlbumSubmitted(
    MediaAlbumSubmitted event,
    Emitter<MediaState> emit,
  ) async {
    emit(state.copyWith(formzStatus: FormzStatus.submissionInProgress));

    final myFiles = <MultipartFile>[];

    final paths = <String>[];

    // Преобразование каждого фото из списка в объект типа MultipartFile
    for (final image in state.images) {
      final photo = await image.file;
      paths.add(photo!.path);
      myFiles.add(
        await MultipartFile.fromPath('', photo.path),
      );
    }

    try {
      final response = await _mediaRepository.addAlbum(
        title: state.inputAlbumTitle.value,
        author: event.author,
        groupId: state.selectedGroupId,
        files: myFiles,
      );

      // Проверка на ошибку
      if (response == false || response == null) {
        throw Exception();
      } else {
        // Ставлю заново загрузку списка медиа
        return emit(
          state.copyWith(
            status: MediaStatus.initial,
            albumsPage: 0,
            videosPage: 0,
            formzStatus: FormzStatus.submissionSuccess,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(formzStatus: FormzStatus.submissionFailure));
    }
  }

  /// Подтверждение выбора фотографий для альбома.
  ///
  /// Список фото зносится в стейт.
  ///
  /// Вызывается когда выбираются изображения для альбома.
  void _onImagesPicked(
    MediaImagesPicked event,
    Emitter<MediaState> emit,
  ) {
    return emit(
      state.copyWith(
        images: event.images,
      ),
    );
  }

  /// Загрузка следующей страницы списка видео.
  Future<void> _onVideoLoadedMore(
    MediaVideoLoadedMore event,
    Emitter<MediaState> emit,
  ) async {
    if (state.hasReachedVideosMax) return;

    try {
      final videos =
          await _mediaRepository.getVideos(videosPage: state.videosPage);

      // Дополняю список новыми загруженными данными
      emit(
        state.copyWith(
          videos: List.of(state.videos)..addAll(videos),
          videosPage: state.videosPage + 1,
          hasReachedVideosMax: videos.length < 20,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: MediaStatus.failure));
    }
  }

  /// Загрузка следующей страницы списка альбомов.
  Future<void> _onAlbumLoadedMore(
    MediaAlbumLoadedMore event,
    Emitter<MediaState> emit,
  ) async {
    if (state.hasReachedAlbumsMax) return;

    try {
      final albums =
          await _mediaRepository.getAlbums(albumsPage: state.albumsPage);

      emit(
        state.copyWith(
          albums: List.of(state.albums)..addAll(albums),
          albumsPage: state.albumsPage + 1,
          hasReachedAlbumsMax: albums.length < 20,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: MediaStatus.failure));
    }
  }

  /// Получение списка медиа.
  ///
  /// Вызывается при первоначальной загрузке медиа [Video] & [Album].
  Future<void> _onMediaFetched(
    MediaFetched event,
    Emitter<MediaState> emit,
  ) async {
    final connectivity = await getIt.getAsync<ConnectivityResult>();

    if (state.status == MediaStatus.initial ||
        state.status == MediaStatus.failure) {
      // Проверяю подключено ли устройство к интернету и
      // Если статус failure - изменяю на статус initial для отображения шиммера
      if ((connectivity == ConnectivityResult.mobile ||
              connectivity == ConnectivityResult.wifi) &&
          state.status == MediaStatus.failure) {
        emit(
          state.copyWith(
            status: MediaStatus.initial,
          ),
        );
      }
    }

    try {
      final albums =
          await _mediaRepository.getAlbums(albumsPage: state.albumsPage);

      final videos =
          await _mediaRepository.getVideos(videosPage: state.videosPage);

      return emit(
        state.copyWith(
          status: MediaStatus.success,
          albums: albums,
          videos: videos,
          albumsPage: state.albumsPage + 1,
          videosPage: state.videosPage + 1,
          hasReachedAlbumsMax: albums.length < 20,
          hasReachedVideosMax: videos.length < 20,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: MediaStatus.failure));
    }
  }
}
