import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:petrov_hockey_academy_flutter/profile_data/profile_data.dart';
import 'package:petrov_hockey_academy_flutter/repositories/profile_data_repository.dart';

part 'profile_data_event.dart';
part 'profile_data_state.dart';

/// Блок для взаимодействия пользователя с его собственными данными профиля:
/// Просмотр, Редактирование(ФИО, номер телефона, email, пароль)
///
/// [ProfileDataBloc] имеет зависимость от [AuthenticationRepository] для отправки запросов,
/// требующих токен пользователя
class ProfileDataBloc extends Bloc<ProfileDataEvent, ProfileDataState> {
  ProfileDataBloc({
    required this.httpClient,
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const ProfileDataState()) {
    on<ProfileDataFetched>(_onProfileDataFetched);
    on<ProfileDataInputDataChanged>(_onInputDataChanged);
    on<ProfileDataInputEmailChanged>(_onPInputEmailChanged);
    on<ProfileDataPickedImageChanged>(_onPickedImageChanged);
    on<ProfileDataFirstNameSubmitted>(_onFirstNameSubmitted);
    on<ProfileDataMiddleNameSubmitted>(_onMiddleNameSubmitted);
    on<ProfileDataLastNameSubmitted>(_onLastNameSubmitted);
    on<ProfileDataPhoneNumberSubmitted>(_onPhoneNumberSubmitted);
    on<ProfileDataEmailSubmetted>(_onEmailSubmetted);
    on<ProfileDataPickedImageSubmitted>(_onPickedImageSubmitted);
    on<ProfileDataInputClosed>(_onInputClosed);
  }

  final http.Client httpClient;

  final AuthenticationRepository _authenticationRepository;

  final getIt = GetIt.instance;

  final _profileDataRepository = ProfileDataRepository();

  /// Отправка запроса на изменение email
  Future<void> _onEmailSubmetted(
    ProfileDataEmailSubmetted event,
    Emitter<ProfileDataState> emit,
  ) async {
    if (!state.formzStatus.isValidated) return;

    emit(
      state.copyWith(
        formzStatus: FormzStatus.submissionInProgress,
      ),
    );

    try {
      final isSuccess = await _profileDataRepository.changeEmail(
          email: state.inputEmail.value);

      // Обновление email локально в приложении после ответа сервера
      if (isSuccess) {
        await _authenticationRepository.updateEmail(
          email: state.inputEmail.value,
        );
        return emit(
          state.copyWith(
            profileData: ProfileData(
              firstName: state.profileData.firstName,
              middleName: state.profileData.middleName,
              lastName: state.profileData.lastName,
              phoneNumber: state.profileData.phoneNumber,
              photo: state.profileData.photo,
              isRedactor: state.profileData.isRedactor,
              email: state.inputEmail.value,
            ),
            inputData: const InputData.pure(),
            formzStatus: FormzStatus.submissionSuccess,
          ),
        );
      } else {
        throw Exception();
      }
    } catch (_) {
      emit(state.copyWith(formzStatus: FormzStatus.submissionFailure));
    }
  }

  /// Отправка запроса на изменение аватара пользователя
  Future<void> _onPickedImageSubmitted(
    ProfileDataPickedImageSubmitted event,
    Emitter<ProfileDataState> emit,
  ) async {
    emit(state.copyWith(imageStatus: ImageStatus.inProgrerss));
    // Преобразование в MultipartFile
    final myFile =
        await MultipartFile.fromPath('', state.pickedImageFile.photo!.path);

    try {
      final isSuccess = await _profileDataRepository.setAvatar(myFile: myFile);

      if (isSuccess == null) {
        throw Exception();
      }

      // Если в теле данных ответа не пусто - изменение произошло успешно
      else {
        // Запрос на получение ссылки обновленнного аватара пользователя
        final avatar = await _profileDataRepository.getAvatar();
        if (avatar == null) {
          throw Exception();
        }

        // Если в теле ответа не пусто - изменяю данные локально
        else {
          return emit(
            state.copyWith(
              profileData: ProfileData(
                firstName: state.profileData.firstName,
                middleName: state.profileData.middleName,
                lastName: state.profileData.lastName,
                phoneNumber: state.profileData.phoneNumber,
                photo: (((avatar['clientSpace'] as Map<String, dynamic>)['me']
                        as Map<String, dynamic>)['avatar']
                    as Map<String, dynamic>)['filename'] as String,
                isRedactor: state.profileData.isRedactor,
                email: state.profileData.email,
              ),
              imageStatus: ImageStatus.success,
              pickedImageFile: PickedImage.empty,
            ),
          );
        }
      }
    } catch (_) {
      emit(state.copyWith(imageStatus: ImageStatus.failure));
    }
  }

  /// Вызывается при изменении выбранного изображения аватара
  void _onPickedImageChanged(
    ProfileDataPickedImageChanged event,
    Emitter<ProfileDataState> emit,
  ) {
    emit(state.copyWith(imageStatus: ImageStatus.initial));

    if (event.pickedImageFile != null) {
      return emit(
        state.copyWith(
          pickedImageFile: PickedImage(photo: event.pickedImageFile),
          imageStatus: ImageStatus.changed,
        ),
      );
    }
  }

  /// Возврат к значениям поумолчанию при закрытии вручуню пользователем формы редактирования данных.
  /// Возвращает значение [ProfileDataState] к значению по умолчанию.
  void _onInputClosed(
    ProfileDataInputClosed event,
    Emitter<ProfileDataState> emit,
  ) {
    return emit(
      state.copyWith(
        inputData: const InputData.pure(),
        inputEmail: const Email.pure(),
        imageStatus: ImageStatus.initial,
        pickedImageFile: PickedImage.empty,
        formzStatus: FormzStatus.pure,
      ),
    );
  }

  /// Отправка запроса на изменение Имени пользователя
  Future<void> _onFirstNameSubmitted(
    ProfileDataFirstNameSubmitted event,
    Emitter<ProfileDataState> emit,
  ) async {
    if (!state.formzStatus.isValidated) return;

    emit(
      state.copyWith(formzStatus: FormzStatus.submissionInProgress),
    );

    try {
      final isSuccess = await _profileDataRepository.changeFirstName(
          firstName: state.inputData.value);

      // Если запрос завершился успешно
      //
      // Обновление Имени локально в приложении после ответа сервера
      if (isSuccess) {
        return emit(
          state.copyWith(
            profileData: ProfileData(
              firstName: state.inputData.value,
              middleName: state.profileData.middleName,
              lastName: state.profileData.lastName,
              phoneNumber: state.profileData.phoneNumber,
              photo: state.profileData.photo,
              isRedactor: state.profileData.isRedactor,
              email: state.profileData.email,
            ),
            inputData: const InputData.pure(),
            formzStatus: FormzStatus.submissionSuccess,
          ),
        );
      } else {
        throw Exception();
      }
    } catch (_) {
      emit(state.copyWith(formzStatus: FormzStatus.submissionFailure));
    }
  }

  /// Отправка запроса на изменение Фамилии пользователя
  Future<void> _onMiddleNameSubmitted(
    ProfileDataMiddleNameSubmitted event,
    Emitter<ProfileDataState> emit,
  ) async {
    if (!state.formzStatus.isValidated) return;

    emit(state.copyWith(formzStatus: FormzStatus.submissionInProgress));

    try {
      final isSuccess = await _profileDataRepository.changeMiddleName(
          middleName: state.inputData.value);

      // Если запрос завершился успешно
      //
      // Обновление Фамилии локально в приложении после ответа сервера
      if (isSuccess) {
        return emit(
          state.copyWith(
            profileData: ProfileData(
              firstName: state.profileData.firstName,
              middleName: state.inputData.value,
              lastName: state.profileData.lastName,
              phoneNumber: state.profileData.phoneNumber,
              photo: state.profileData.photo,
              isRedactor: state.profileData.isRedactor,
              email: state.profileData.email,
            ),
            inputData: const InputData.pure(),
            formzStatus: FormzStatus.submissionSuccess,
          ),
        );
      } else {
        throw Exception();
      }
    } catch (_) {
      emit(state.copyWith(formzStatus: FormzStatus.submissionFailure));
    }
  }

  /// Отправка запроса на изменение Отчества пользователя
  Future<void> _onLastNameSubmitted(
    ProfileDataLastNameSubmitted event,
    Emitter<ProfileDataState> emit,
  ) async {
    if (!state.formzStatus.isValidated) return;

    emit(state.copyWith(formzStatus: FormzStatus.submissionInProgress));

    try {
      final isSuccess = await _profileDataRepository.changeLastName(
          lastName: state.inputData.value);

      // Если запрос завершился успешно
      //
      // Обновление Имени локально в приложении после ответа сервера
      if (isSuccess) {
        return emit(
          state.copyWith(
            profileData: ProfileData(
              firstName: state.profileData.firstName,
              middleName: state.profileData.middleName,
              lastName: state.inputData.value,
              phoneNumber: state.profileData.phoneNumber,
              photo: state.profileData.photo,
              isRedactor: state.profileData.isRedactor,
              email: state.profileData.email,
            ),
            inputData: const InputData.pure(),
            formzStatus: FormzStatus.submissionSuccess,
          ),
        );
      } else {
        throw Exception();
      }
    } catch (_) {
      emit(state.copyWith(formzStatus: FormzStatus.submissionFailure));
    }
  }

  /// Отправка запроса на изменение Номера телефона пользователя
  Future<void> _onPhoneNumberSubmitted(
    ProfileDataPhoneNumberSubmitted event,
    Emitter<ProfileDataState> emit,
  ) async {
    if (!state.formzStatus.isValidated) return;

    emit(state.copyWith(formzStatus: FormzStatus.submissionInProgress));

    try {
      final isSuccess = await _profileDataRepository.changePhoneNumber(
          phone: state.inputData.value);

      // Если запрос завершился успешно
      //
      // Обновление Имени локально в приложении после ответа сервера
      if (isSuccess) {
        return emit(
          state.copyWith(
            profileData: ProfileData(
              firstName: state.profileData.firstName,
              middleName: state.profileData.middleName,
              lastName: state.profileData.lastName,
              phoneNumber: '+${state.inputData.value}',
              photo: state.profileData.photo,
              isRedactor: state.profileData.isRedactor,
              email: state.profileData.email,
            ),
            inputData: const InputData.pure(),
            formzStatus: FormzStatus.submissionSuccess,
          ),
        );
      } else {
        throw Exception();
      }
    } catch (_) {
      emit(state.copyWith(formzStatus: FormzStatus.submissionFailure));
    }
  }

  /// Валидация введенного значения Фамилии/Имени/Отчества/Номера Телефона
  void _onInputDataChanged(
    ProfileDataInputDataChanged event,
    Emitter<ProfileDataState> emit,
  ) {
    final inputData = InputData.dirty(event.inputData);
    return emit(
      state.copyWith(
        inputData: inputData,
        formzStatus: Formz.validate([inputData]),
      ),
    );
  }

  /// Валидация введенного значения email
  void _onPInputEmailChanged(
    ProfileDataInputEmailChanged event,
    Emitter<ProfileDataState> emit,
  ) {
    final inputEmail = Email.dirty(event.inputEmail);

    return emit(
      state.copyWith(
        inputEmail: inputEmail,
        formzStatus: Formz.validate([inputEmail]),
      ),
    );
  }

  /// Вызывается при первоначальной загрузке данных пользователя [ProfileData] & [Group]
  Future<void> _onProfileDataFetched(
    ProfileDataFetched event,
    Emitter<ProfileDataState> emit,
  ) async {
    if (state.dataStatus == ProfileDataStatus.initial ||
        state.dataStatus == ProfileDataStatus.failure) {
      final connectivity = await getIt.getAsync<ConnectivityResult>();

      // Проверяю подключено ли устройство к интернету
      // Если статус failure - изменяю на статус initial для отображения шиммера
      if (connectivity == ConnectivityResult.mobile ||
          connectivity == ConnectivityResult.wifi) {
        if (state.dataStatus == ProfileDataStatus.failure) {
          emit(
            state.copyWith(
              dataStatus: ProfileDataStatus.initial,
            ),
          );
        }
      }
    }
    try {
      final profileData = await _profileDataRepository.getProfileData();

      final groups = await _profileDataRepository.getGroups();

      return emit(
        state.copyWith(
          dataStatus: ProfileDataStatus.success,
          profileData: profileData,
          groups: groups,
        ),
      );
    } catch (_) {
      emit(state.copyWith(dataStatus: ProfileDataStatus.failure));
    }
  }
}
