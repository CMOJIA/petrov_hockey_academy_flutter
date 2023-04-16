import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import 'package:petrov_hockey_academy_flutter/graphQL/graphql_service.dart';
import 'package:petrov_hockey_academy_flutter/graphQL/queries.dart' as query;
import 'package:petrov_hockey_academy_flutter/notifications/notifications.dart';

final getIt = GetIt.instance;

/// Репозиторий для отправки и получения данных связанных с уведомлениями
class NotificationsRepository {
  NotificationsRepository();

  /// Отправка запроса на получение списка [UserNotification].
  ///
  /// Перебираю каждый элемент и создаю для каждого экземпляр класса.
  Future<List<UserNotification>> getNotifications([int page = 1]) async {
    final format = DateFormat('yyyy-MM-dd HH:mm:ss');
    try {
      final response = await getIt<GraphQLService>().performQuery(
        query.getNotifications,
        variables: {'page': page},
      );

      // Если уведомлений нет
      if (((response.data?['clientSpace']
                  as Map<String, dynamic>)['notification']
              as Map<String, dynamic>)['data'] ==
          null) {
        return [];
      }

      final data = ((response.data?['clientSpace']
              as Map<String, dynamic>)['notification']
          as Map<String, dynamic>)['data'] as List;

      return data.map((dynamic json) {
        final map = json as Map<String, dynamic>;
        // На основе типа уведомления ставлю заголовок
        String type;
        switch (map['type'] as String) {
          case 'training_created':
            type = 'Запись на занятие';
            break;
          case 'training_canceled':
            type = 'Отмена занятия';
            break;
          case 'training_changed':
            type = 'Изменение занятия';
            break;
          case 'payment':
            type = 'Изменение статуса оплаты';
            break;
          case 'subscription':
            type = 'Продление абонемента';
            break;
          default:
            type = 'Уведомление';
        }

        return UserNotification(
          createdDt: format.parse(map['created_at'] as String),
          id: map['notification_id'] as String,
          isRead: map['is_read'] as int,
          text: map['text'] as String,
          type: type,
        );
      }).toList();
    } catch (_) {
      rethrow;
    }
  }

  /// Отправка запроса на прочтение уведолмения
  Future<int> readingNotification({required String id}) async {
    try {
      final response = await getIt.get<GraphQLService>().performQuery(
        query.notificateUpdate,
        variables: {'is_read': 1, 'notification_id': id},
      );
      return response.data?['notificateUpdate'];
    } catch (_) {
      rethrow;
    }
  }
}
