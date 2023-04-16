part of 'login_cubit.dart';

enum EmailUpdatingStatus { initial, updated }

class LoginState extends Equatable {
  const LoginState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.status = FormzStatus.pure,
    this.errorMessage,
    this.newPassword = const Password.pure(),
    this.passwordConfirmation = const Password.pure(),
    this.isVisibleConfirmationPassword = true,
    this.isVisibleNewPassword = true,
  });

  final Email email;
  final Password password;
  final FormzStatus status;
  final String? errorMessage;
  final Password newPassword;
  final Password passwordConfirmation;
  final bool isVisibleConfirmationPassword;
  final bool isVisibleNewPassword;

  @override
  List<Object> get props => [
        email,
        password,
        status,
        newPassword,
        passwordConfirmation,
        isVisibleConfirmationPassword,
        isVisibleNewPassword
      ];

  LoginState copyWith({
    Email? email,
    Password? password,
    FormzStatus? status,
    String? errorMessage,
    Password? newPassword,
    Password? passwordConfirmation,
    bool? isVisibleConfirmationPassword,
    bool? isVisibleNewPassword,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      newPassword: newPassword ?? this.newPassword,
      passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
      isVisibleConfirmationPassword:
          isVisibleConfirmationPassword ?? this.isVisibleConfirmationPassword,
      isVisibleNewPassword: isVisibleNewPassword ?? this.isVisibleNewPassword,
    );
  }
}
