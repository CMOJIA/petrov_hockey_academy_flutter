import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:petrov_hockey_academy_flutter/login/login.dart';
import 'package:petrov_hockey_academy_flutter/recovery/recovery.dart';
import 'package:petrov_hockey_academy_flutter/transitions/transitions.dart';
import 'package:url_launcher/url_launcher.dart';

///  Форма ввода логина и пароля для входа в приложение.
class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status.isSubmissionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ??
                    'Ошибка аутенфикации. Проверьте подключение к интернету или попробуйте позже.'),
              ),
            );
        }
      },
      child: Align(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 200,
              ),
              const SizedBox(height: 16),
              _EmailInput(),
              const SizedBox(height: 8),
              _PasswordInput(),
              const SizedBox(height: 8),
              _LoginButton(),
              const SizedBox(height: 8),
              _RecoveryButton(),
              const SizedBox(height: 50),
              _PrivacyPolicy(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Кнопка для перехода к открытия страницы сайти политики конфиденциальности.
class _PrivacyPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'Используя данное приложение вы соглашаетесь с',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 14,
            ),
          ),
          // Ссылка на Политику Конфиденциальности академии
          //
          // Открывается в браузере
          GestureDetector(
            onTap: _launchURL,
            child: Text(
              'Политикой Конфиденциальности',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14,
                decoration: TextDecoration.underline,
                decorationColor: Theme.of(context).primaryColor,
                decorationThickness: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Функция открытия ссылки в браузере.
  Future<void> _launchURL() async {
    final url = Uri.parse('https://petrovacademy.ru/page/policy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}

/// Поле ввода email.
///
/// На каждое изменение проводится валидация введенного значения
class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_emailInput_textField'),
          onChanged: (email) => context.read<LoginCubit>().emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Логин',
            helperText: '',
            prefixIcon:
                const Icon(Icons.person_rounded, color: Color(0xFF172439)),
            errorText: state.email.invalid ? 'Неверный email' : null,
          ),
        );
      },
    );
  }
}

/// Поле ввода пароля.
///
/// На каждое изменение проводится валидация введенного значения
class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_passwordInput_textField'),
          onChanged: (password) =>
              context.read<LoginCubit>().passwordChanged(password),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Пароль',
            helperText: '',
            prefixIcon: const Icon(Icons.key_rounded, color: Color(0xFF172439)),
            errorText: state.password.invalid ? 'Недопустимый пароль' : null,
          ),
        );
      },
    );
  }
}

/// Кнопка авторзации.
///
/// Активна если поля email & password прошли валидацию.
class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
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
                    ? () => context.read<LoginCubit>().logInWithCredentials()
                    : null,
                child: const Text(
                  'Войти',
                ),
              );
      },
    );
  }
}

/// Кнопка перехода к экрану восстановления пароля к учетной записи.
class _RecoveryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.push(context, SlideRightRoute(
        builder: (
          ctx,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return const RecoveryPage();
        },
      )),
      child: Text(
        'Проблема со входом?',
        style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
      ),
    );
  }
}
