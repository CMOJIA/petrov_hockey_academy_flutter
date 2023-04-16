import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import 'package:petrov_hockey_academy_flutter/app/app.dart';
import 'package:petrov_hockey_academy_flutter/timetables/timetables.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  Bloc.observer = AppBlocObserver();

  await Firebase.initializeApp();

  await setupFlutterNotifications();

  final authenticationRepository = AuthenticationRepository();

  // Инстанс проверки подклбчения устройства, дергаю в блоках по требованию
  GetIt.instance.registerFactoryAsync<ConnectivityResult>(
      () => (Connectivity().checkConnectivity()));

  // Попытка автологина
  await authenticationRepository.tryAutoLogin();

  runApp(App(authenticationRepository: authenticationRepository));
}
