import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petrov_hockey_academy_flutter/recovery/recovery.dart';

/// Экран восстановления пароля к учетной записи по введенному email
class RecoveryPage extends StatelessWidget {
  const RecoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          title: const Text('Проблемы со входом?')),
      body: BlocProvider<RecoveryCubit>(
        create: (_) => RecoveryCubit(context.read<AuthenticationRepository>()),
        child: const RecoveryForm(),
      ),
    );
  }
}
