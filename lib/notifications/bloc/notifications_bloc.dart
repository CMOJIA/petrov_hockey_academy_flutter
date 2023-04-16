import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:petrov_hockey_academy_flutter/graphQL/graphql_service.dart';
import 'package:petrov_hockey_academy_flutter/notifications/notifications.dart';
import 'package:petrov_hockey_academy_flutter/repositories/notifications_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

/// Блок для взаимодействия с уведомлениями пользователя:
/// Просмотр, Прочтение
///
/// [NotificationsBloc] имеет зависимость от [AuthenticationRepository] для отправки запросов,
/// требующих токен пользователя
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({
    required AuthenticationRepository authenticationRepository,
    required this.httpClient,
  })  : _authenticationRepository = authenticationRepository,
        super(const NotificationsState()) {
    on<NotificationsFetched>(_onNotificationsFetched);
    on<NotificationsIsReaded>(_onIsReaded);
    on<NotificationsStatusRefreshed>(
      _onStatusRefreshed,
    );
    on<NotificationsLoadedMore>(
      _onLoadedMore,
      transformer: droppable(),
    );
  }

  final http.Client httpClient;

  final AuthenticationRepository _authenticationRepository;

  final _notificationsRepository = NotificationsRepository();

  final getIt = GetIt.instance;

  /// Возвращение статуса стейта к значению по умолчанию,
  /// чтобы повторить первоначальную загрузку.
  /// Только для RefreshIndicator
  void _onStatusRefreshed(
    NotificationsStatusRefreshed event,
    Emitter<NotificationsState> emit,
  ) {
    // в GraphQLClient встроенный кэш
    // получается, что  когда использую  рефреш - ничего не происходит,
    // т.к. такой запрос и ответ на него уже хранится в кеше экземпляра класса созданного тут
    // поэтому заново регистрирую синглтон
    //
    // В будущем избавиться от рефреша путем подписки на уведомления
    getIt.registerSingleton<GraphQLService>(
      GraphQLService(_authenticationRepository.currentUser.token),
    );

    return emit(
      state.copyWith(
        status: NotificationFetchedStatus.initial,
        hasReachedMax: false,
        page: 1,
      ),
    );
  }

  /// Запрос о прочтении увдомления на сервер.
  ///
  /// После ответа сервера об успехе - изменяется статус локально.
  Future<void> _onIsReaded(
    NotificationsIsReaded event,
    Emitter<NotificationsState> emit,
  ) async {
    // Доп проверка, если увеждомление уже прочтено
    if (event.notification.isRead == 1) return;

    final newItem = event.notification.copyWith(isRead: 1);

    final notificationIndex =
        state.notifications.indexWhere((element) => element.id == newItem.id);

    // Проверка если индекс уведолмения нашелся на устройстве
    if (notificationIndex >= 0) {
      emit(
        state.copyWith(
          isReadStatus: NotificationIsReadSatus.inProgress,
        ),
      );

      try {
        final isReaded = await _notificationsRepository.readingNotification(
            id: event.notification.id);

        // Если увдомление прочиталось
        if (isReaded == 1) {
          state.notifications[notificationIndex] = newItem;
          return emit(
            state.copyWith(
              isReadStatus: NotificationIsReadSatus.changed,
            ),
          );
        }
      } catch (_) {
        rethrow;
      }
    }
    // Иначе добавляю новый экземпляр уведолмения
    else {
      state.notifications.add(newItem);
    }
  }

  /// Получение списка уведомлений
  ///
  /// Вызывается при первоначальной загрузке уведомлений [UserNotification]
  Future<void> _onNotificationsFetched(
    NotificationsFetched event,
    Emitter<NotificationsState> emit,
  ) async {
    final connectivity = await getIt.getAsync<ConnectivityResult>();

    if (state.status == NotificationFetchedStatus.initial ||
        state.status == NotificationFetchedStatus.failure) {
      // Проверяю подключено ли устройство к интернету и
      // Если статус failure - изменяю на статус initial для отображения шиммера
      if ((connectivity == ConnectivityResult.mobile ||
              connectivity == ConnectivityResult.wifi) &&
          state.status == NotificationFetchedStatus.failure) {
        emit(
          state.copyWith(
            status: NotificationFetchedStatus.initial,
          ),
        );
      }
    }

    try {
      final notifications = await _notificationsRepository.getNotifications();

      return emit(
        state.copyWith(
          status: NotificationFetchedStatus.success,
          notifications: notifications,
          page: state.page + 1,
          hasReachedMax: notifications.length < 20,
          count: notifications.where((element) => element.isRead == 0).length,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: NotificationFetchedStatus.failure,
        ),
      );
    }
  }

  /// Загрузка следующей страницы списка уведомлений
  Future<void> _onLoadedMore(
    NotificationsLoadedMore event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      if (state.hasReachedMax) return;

      final notifications =
          await _notificationsRepository.getNotifications(state.page);

      return emit(
        state.copyWith(
          notifications: List.of(state.notifications)..addAll(notifications),
          page: state.page + 1,
          hasReachedMax: notifications.length < 20,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: NotificationFetchedStatus.failure,
        ),
      );
    }
  }
}
