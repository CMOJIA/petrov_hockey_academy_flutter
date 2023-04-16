import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'app_event.dart';
part 'app_state.dart';

/// [AppBloc] отвечает за управление глобальным состоянием приложения.
/// Он зависит от [AuthenticationRepository] и подписывается на стрим user,
/// чтобы создавать новые состояния в ответ на изменения текущего пользователя.
class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(
          authenticationRepository.currentUser.isNotEmpty
              ? AppState.authenticated(authenticationRepository.currentUser)
              : const AppState.unauthenticated(),
        ) {
    on<AppUserChanged>(_onUserChanged);
    on<AppLogoutRequested>(_onLogoutRequested);
    on<AppSelectedTabsPage>(_onSelectedTabsPage);
    // Подписка на стрим user, при получении user статус аутенфикации меняется
    _userSubscription = _authenticationRepository.user.listen(
      (user) => add(AppUserChanged(user)),
    );
  }

  final AuthenticationRepository _authenticationRepository;
  late final StreamSubscription<User> _userSubscription;

  /// Вызывается при изменении индекса страницы BottomNavigationBar
  void _onSelectedTabsPage(
    AppSelectedTabsPage event,
    Emitter<AppState> emit,
  ) {
    return emit(
      state.copyWith(
        selectedPage: event.index,
      ),
    );
  }

  /// Вызывается когда в стриме [_authenticationRepository.user] появляется [User]
  Future<void> _onUserChanged(
      AppUserChanged event, Emitter<AppState> emit) async {
    emit(
      event.user.isNotEmpty
          ? AppState.authenticated(event.user)
          : const AppState.unauthenticated(),
    );
  }

  /// Вызывается при нажатии на кнопку выхода из аккаунта
  void _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) {
    unawaited(_authenticationRepository.logOut());
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
