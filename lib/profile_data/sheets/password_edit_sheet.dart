import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:petrov_hockey_academy_flutter/login/login.dart';
import 'package:petrov_hockey_academy_flutter/universal/universal.dart';

// Форма в виде ModalBottomSheet для редактирования пароля
void updatePassword(
  BuildContext context,
) {
  showModalBottomSheet<void>(
    isScrollControlled: true,
    context: context,
    builder: (_) {
      return BlocProvider.value(
        value: BlocProvider.of<LoginCubit>(context),
        child: BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state.status.isSubmissionSuccess) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    margin: const EdgeInsets.all(4),
                    content: const Text(
                      'Пароль успешно изменен.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
            }
            if (state.status.isSubmissionFailure) {
              warningDialog(
                context: context,
                title: 'Ошибка',
                content:
                    'Не удалось сохранить изменения. Проверьте подключение к интернету или попробуйте позже.',
              ).whenComplete(
                () => context.read<LoginCubit>().errorDialogClosed(),
              );
            }
          },
          child: BlocBuilder<LoginCubit, LoginState>(
            builder: (context, state) {
              return SheetPasswordContent(state: state);
            },
          ),
        ),
      );
    },
  ).whenComplete(
    () => context.read<LoginCubit>().modalSheetClosed(),
  );
}

/// Контент ModalBottomSheet для редактирования пароля
class SheetPasswordContent extends StatelessWidget {
  final LoginState state;
  const SheetPasswordContent({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Изменение пароля',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            _NewPasswordTextField(
              state: state,
            ),
            SizedBox(
              width: double.infinity,
              child: Text(
                'Введите новый пароль еще раз:',
                style: Theme.of(context).textTheme.displayMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _ConfirmedPasswordTextField(
              state: state,
            ),
            _SubmitButton(
              state: state,
            )
          ],
        ),
      ),
    );
  }
}

/// Кнопка подтверждения изменения пароля и отправки запроса на изменение
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.state});
  final LoginState state;

  @override
  Widget build(BuildContext context) {
    if (state.status.isSubmissionInProgress)
      return SizedBox(
        height: 50,
        width: 50,
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColorDark,
        ),
      );
    else
      return ElevatedButton(
        // Кнопка активна если введенные значения корректны и
        // значение нового пароля совпадает с значение подтврждения  пароля
        onPressed: state.status.isValidated &&
                state.newPassword.value == state.passwordConfirmation.value
            ? () => context.read<LoginCubit>().passwordUpdated()
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColorDark,
          disabledBackgroundColor: Colors.black12,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text(
          'Сохранить',
        ),
      );
  }
}

/// Форма ввода пароля второй раз для подтверждения
class _ConfirmedPasswordTextField extends StatelessWidget {
  const _ConfirmedPasswordTextField({required this.state});
  final LoginState state;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 95,
        child: TextField(
          key: const Key(
            'passwordConfirmationInput_textField',
          ),
          maxLength: 255,
          obscureText: state.isVisibleConfirmationPassword,
          onChanged: (passwordConfirmation) => context
              .read<LoginCubit>()
              .confirmationPasswordChanged(passwordConfirmation),
          decoration: InputDecoration(
            counterText: '',
            hintText: 'Подтвердите пароль',
            prefixIcon: const Icon(
              Icons.key,
            ),
            suffixIcon: InkWell(
              borderRadius: BorderRadius.circular(30),
              child: Icon(
                state.isVisibleConfirmationPassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
              ),
              onTap: () => context
                  .read<LoginCubit>()
                  .passwordConfirmationVisibilityChanged(
                    isVisible: !state.isVisibleConfirmationPassword,
                  ),
            ),
            errorText: state.passwordConfirmation.invalid
                ? '8 и более символов, латинские буквы и цифры'
                : state.passwordConfirmation.valid &&
                        state.newPassword.value !=
                            state.passwordConfirmation.value
                    ? 'Введенные пароли не совпадают'
                    : null,
          ),
        ),
      ),
    );
  }
}

/// Форма ввода нового пароля
class _NewPasswordTextField extends StatelessWidget {
  const _NewPasswordTextField({required this.state});
  final LoginState state;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 95,
        child: TextField(
          key: const Key('newPasswordInput_textField'),
          maxLength: 255,
          autofocus: true,
          obscureText: state.isVisibleNewPassword,
          onChanged: (newPassword) =>
              context.read<LoginCubit>().newPasswordChanged(newPassword),
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            counterText: '',
            hintText: 'Новый пароль',
            prefixIcon: Icon(
              Icons.password_rounded,
            ),
            suffixIcon: InkWell(
              borderRadius: BorderRadius.circular(30),
              child: Icon(
                state.isVisibleNewPassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
              ),
              onTap: () =>
                  context.read<LoginCubit>().newPasswordVisibilityChanged(
                        isVisible: !state.isVisibleNewPassword,
                      ),
            ),
            errorText: state.newPassword.invalid
                ? '8 и более символов, латинские буквы и цифры'
                : null,
          ),
        ),
      ),
    );
  }
}
