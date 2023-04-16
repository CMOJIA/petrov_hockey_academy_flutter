import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:petrov_hockey_academy_flutter/graphQL/graphql_service.dart';
import 'package:petrov_hockey_academy_flutter/graphQL/queries.dart' as query;

part 'login_state.dart';

/// [LoginCubit] имеет зависимость от [AuthenticationRepository] для входа пользователя с помощью учетных данных
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository) : super(const LoginState());

  final AuthenticationRepository _authenticationRepository;

  /// Сбрасывает ошибку воникающую при  изменении пароля пользователя.
  ///
  /// Т.к. ошибка может случаться только или на стороне API или из-за отстувия  интернет-подключения
  /// не нужно заствалвять пользователя снова ввводить пароль, чтобы проводить валидацию введенного значения
  void errorDialogClosed() {
    emit(
      state.copyWith(
        status: FormzStatus.valid,
      ),
    );
  }

  /// Скрытие/отображение вводимого подтверждающего пароля при его изменении в приложении.
  void passwordConfirmationVisibilityChanged({required bool isVisible}) {
    emit(
      state.copyWith(
        isVisibleConfirmationPassword: isVisible,
      ),
    );
  }

  /// Скрытие/отображение вводимого нового пароля при его изменении в приложении.
  void newPasswordVisibilityChanged({required bool isVisible}) {
    emit(
      state.copyWith(
        isVisibleNewPassword: isVisible,
      ),
    );
  }

  /// Возвразщает значения по умолчанию в стейте, когда форма изменения пароля/email была закрыта пользователем вручную
  void modalSheetClosed() {
    const password = Password.pure();

    const email = Email.pure();

    emit(
      state.copyWith(
        status: FormzStatus.pure,
        password: password,
        newPassword: password,
        passwordConfirmation: password,
        email: email,
        isVisibleConfirmationPassword: true,
        isVisibleNewPassword: true,
      ),
    );
  }

  /// Валидация вводимого email (при авторизации)
  void emailChanged(String value) {
    final email = Email.dirty(value);

    emit(
      state.copyWith(
        email: email,
        status: Formz.validate([email]),
      ),
    );
  }

  /// Валидация вводимого пароля (при авторизации)
  void passwordChanged(String value) {
    final password = Password.dirty(value);

    emit(
      state.copyWith(
        password: password,
        status: Formz.validate([state.email, password]),
      ),
    );
  }

  /// Валидация вводимого нового пароля (при обновлении пароля от аккаунта_
  void newPasswordChanged(String value) {
    final newPassword = Password.dirty(value);

    emit(
      state.copyWith(
        newPassword: newPassword,
        status: Formz.validate([newPassword, state.passwordConfirmation]),
      ),
    );
  }

  /// Валидация вводимого подтверждающего пароля (при обновлении пароля от аккаунта)
  void confirmationPasswordChanged(String value) {
    final passwordConfirmation = Password.dirty(value);

    emit(
      state.copyWith(
        passwordConfirmation: passwordConfirmation,
        status: Formz.validate([state.newPassword, passwordConfirmation]),
      ),
    );
  }

  /// Запрос к API на изменение пароля пользователя и обработка результата.
  ///
  /// Переместить в ProfileDataBloc
  Future<void> passwordUpdated() async {
    if (!state.status.isValidated) return;

    const password = Password.pure();

    emit(state.copyWith(status: FormzStatus.submissionInProgress));

    print('udated');

    try {
      final _result = await GetIt.instance<GraphQLService>().performMutation(
        query.setPassword,
        variables: {'password': state.newPassword.value},
      );

      if (_result.hasException) throw Exception();

      if (_result.data?['setPassword'] == true) {
        emit(
          state.copyWith(
            status: FormzStatus.submissionSuccess,
            newPassword: password,
            isVisibleConfirmationPassword: true,
            isVisibleNewPassword: true,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }

  /// Авторизация с помощью логина и пароля
  Future<void> logInWithCredentials() async {
    if (!state.status.isValidated) return;

    emit(state.copyWith(status: FormzStatus.submissionInProgress));

    try {
      await _authenticationRepository.logInWithEmailAndPassword(
        email: state.email.value,
        password: state.password.value,
      );

      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } on LogInWithEmailAndPasswordFailure catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzStatus.submissionFailure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }
}
