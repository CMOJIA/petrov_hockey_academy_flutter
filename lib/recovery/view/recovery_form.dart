import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:petrov_hockey_academy_flutter/recovery/recovery.dart';

/// Форма восстановления пароля пользователя
class RecoveryForm extends StatelessWidget {
  const RecoveryForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecoveryCubit, RecoveryState>(
      listener: (ctx, state) {
        if (state.status.isSubmissionSuccess) {
          _showAlertDialog(context, state.email.value, true);
        } else if (state.status.isSubmissionFailure) {
          _showAlertDialog(context, state.errorMessage, false);
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 2),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RecoveryLabel(),
              _EmailInput(),
              const SizedBox(height: 8),
              _SubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}

void _showAlertDialog(BuildContext context, String? content, bool isSucces) {
  showGeneralDialog<String>(
    context: context,
    pageBuilder: (context, anim1, anim2) {
      return const SizedBox();
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return Transform.scale(
        scale: anim1.value,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: AlertDialog(
            contentPadding: const EdgeInsets.all(20),
            actionsAlignment: MainAxisAlignment.center,
            title: Text(
              isSucces ? 'Проверьте почту!' : 'Ошибка восстановления.',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            content: Text(
              isSucces
                  ? 'Письмо с инструкциями по восстановлению доступа к учетной записи было отправленно на email: $content!'
                  : content ?? 'Проверьте подключение к интернету.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.maybePop(context);
                },
                icon: Icon(
                  Icons.check_rounded,
                  color: Colors.green[600],
                ),
                label: Text(
                  'Ok',
                  style: TextStyle(
                    color: Colors.green[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Заголовок экрана восстановелния
class _RecoveryLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
      child: Text(
        'Восстановление доступа к учетной записи',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColorDark,
        ),
      ),
    );
  }
}

/// Поле ввода email
class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecoveryCubit, RecoveryState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return TextField(
          onChanged: (email) =>
              context.read<RecoveryCubit>().emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Введите адрес электронной почты',
            helperText: 'example@petrovacademy.ru',
            prefixIcon: const Icon(
              Icons.email_rounded,
            ),
            errorText: state.email.invalid ? 'Неверный email' : null,
          ),
        );
      },
    );
  }
}

/// Кнопка отправки запроса на восстановление пароля,
/// к учетной записи привязанной к введенному email
class _SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecoveryCubit, RecoveryState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? CircularProgressIndicator(
                color: Theme.of(context).primaryColorDark,
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: state.status.isValidated
                    ? () =>
                        context.read<RecoveryCubit>().recoveryFormSubmitted()
                    : null,
                child: const Text(
                  'Продолжить',
                ),
              );
      },
    );
  }
}
