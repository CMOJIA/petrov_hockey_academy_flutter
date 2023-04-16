import 'package:authentication_repository/authentication_repository.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:petrov_hockey_academy_flutter/app/app.dart';
import 'package:petrov_hockey_academy_flutter/app/routes/routes.dart';
import 'package:petrov_hockey_academy_flutter/login/login.dart';
import 'package:petrov_hockey_academy_flutter/theme.dart';
import 'package:petrov_hockey_academy_flutter/timetables/timetables.dart';

/// App предоставляет экземпляр [AuthenticationRepository] приложению через [RepositoryProvider],
/// а также создает и предоставляет экземпляр [AppBloc].

class App extends StatelessWidget {
  const App({
    super.key,
    required AuthenticationRepository authenticationRepository,
  }) : _authenticationRepository = authenticationRepository;

  final AuthenticationRepository _authenticationRepository;

  @override
  Widget build(BuildContext context) {
    // Когда приложение прогрузилось, удаляется и SplashScreen
    FlutterNativeSplash.remove();

    return RepositoryProvider.value(
      value: _authenticationRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AppBloc(
              authenticationRepository: _authenticationRepository,
            ),
          ),
          // При смене пользователя, чтобы Bloc не удалялся, т.к нет необходимости заново загружать расписание
          BlocProvider(
            create: (_) => TimetableBloc()..add(TimetableFetched()),
          ),
          BlocProvider<LoginCubit>(
            create: (_) => LoginCubit(_authenticationRepository),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

/// [AppView] использует [AppBloc] и обрабатывает обновление текущего маршрута на основе [AppState].
class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: FlowBuilder<AppStatus>(
        state: context.select((AppBloc bloc) => bloc.state.status),
        onGeneratePages: onGenerateAppViewPages,
      ),
    );
  }
}
