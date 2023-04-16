part of 'media_bloc.dart';

enum MediaStatus { initial, success, failure }

class MediaState extends Equatable {
  const MediaState({
    this.status = MediaStatus.initial,
    this.albums = const <Album>[],
    this.videos = const <Video>[],
    this.albumsPage = 1,
    this.hasReachedAlbumsMax = false,
    this.videosPage = 1,
    this.hasReachedVideosMax = false,
    this.images = const <AssetEntity>[],
    this.inputVideoTitle = const InputVideoTitle.pure(),
    this.inputAlbumTitle = const InputAlbumTitle.pure(),
    this.inputUrl = const InputUrl.pure(),
    this.formzStatus = FormzStatus.pure,
    this.inputAuthor = '',
    this.selectedGroupId = 0,
  });

  final MediaStatus status;
  final List<Album> albums;
  final List<Video> videos;
  final int albumsPage;
  final bool hasReachedAlbumsMax;
  final int videosPage;
  final bool hasReachedVideosMax;
  final List<AssetEntity> images;
  final InputVideoTitle inputVideoTitle;
  final InputAlbumTitle inputAlbumTitle;
  final InputUrl inputUrl;
  final FormzStatus formzStatus;
  final String inputAuthor;
  final int selectedGroupId;

  MediaState copyWith({
    MediaStatus? status,
    List<Album>? albums,
    List<Video>? videos,
    int? albumsPage,
    bool? hasReachedAlbumsMax,
    int? videosPage,
    bool? hasReachedVideosMax,
    List<AssetEntity>? images,
    InputVideoTitle? inputVideoTitle,
    InputAlbumTitle? inputAlbumTitle,
    InputUrl? inputUrl,
    FormzStatus? formzStatus,
    String? inputAuthor,
    int? selectedGroupId,
  }) {
    return MediaState(
      status: status ?? this.status,
      albums: albums ?? this.albums,
      videos: videos ?? this.videos,
      albumsPage: albumsPage ?? this.albumsPage,
      hasReachedAlbumsMax: hasReachedAlbumsMax ?? this.hasReachedAlbumsMax,
      videosPage: videosPage ?? this.videosPage,
      hasReachedVideosMax: hasReachedVideosMax ?? this.hasReachedVideosMax,
      images: images ?? this.images,
      inputVideoTitle: inputVideoTitle ?? this.inputVideoTitle,
      inputAlbumTitle: inputAlbumTitle ?? this.inputAlbumTitle,
      inputUrl: inputUrl ?? this.inputUrl,
      formzStatus: formzStatus ?? this.formzStatus,
      inputAuthor: inputAuthor ?? this.inputAuthor,
      selectedGroupId: selectedGroupId ?? this.selectedGroupId,
    );
  }

  @override
  List<Object> get props => [
        status,
        albums,
        videos,
        albumsPage,
        hasReachedAlbumsMax,
        videosPage,
        hasReachedVideosMax,
        images,
        inputAlbumTitle,
        inputVideoTitle,
        inputUrl,
        formzStatus,
        inputAuthor,
        selectedGroupId,
      ];
}
