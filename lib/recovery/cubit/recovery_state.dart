part of 'recovery_cubit.dart';

class RecoveryState extends Equatable {
  const RecoveryState({
    this.email = const Email.pure(),
    this.status = FormzStatus.pure,
    this.errorMessage,
  });

  final Email email;
  final FormzStatus status;
  final String? errorMessage;

  @override
  List<Object> get props => [email, status];

  RecoveryState copyWith({
    Email? email,
    FormzStatus? status,
    String? errorMessage,
  }) {
    return RecoveryState(
      email: email ?? this.email,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
