import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';

part 'recovery_state.dart';

/// [RecoveryCubit] имеет зависимость от [AuthenticationRepository] для восстановления доступа
///  к учетной записи путем отправки сообщения на введеный email
class RecoveryCubit extends Cubit<RecoveryState> {
  RecoveryCubit(this._authenticationRepository) : super(const RecoveryState());

  final AuthenticationRepository _authenticationRepository;

  /// Валидация вводимого [Email]
  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(
      state.copyWith(
        email: email,
        status: Formz.validate([
          email,
        ]),
      ),
    );
  }

  /// Отправка запроса на восстановление пароля на введенный [Email]
  Future<void> recoveryFormSubmitted() async {
    if (!state.status.isValidated) return;
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authenticationRepository.sendPasswordResetEmail(
        email: state.email.value,
      );
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } on SendPasswordResetEmailFailure catch (e) {
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
