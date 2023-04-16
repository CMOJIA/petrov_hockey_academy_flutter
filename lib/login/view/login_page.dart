import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petrov_hockey_academy_flutter/login/login.dart';

/// Экран ввода логина и пароля для авторизации в приложении.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static Page<void> page() => const MaterialPage<void>(child: LoginPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          title: const Text('Войти')),
      body: BlocProvider.value(
        value: BlocProvider.of<LoginCubit>(context),
        child: const LoginForm(),
      ),
    );
  }
}
