import 'package:intl/intl.dart';

import 'package:get_it/get_it.dart';
import 'package:petrov_hockey_academy_flutter/graphQL/graphql_service.dart';
import 'package:petrov_hockey_academy_flutter/graphQL/queries.dart' as query;
import 'package:petrov_hockey_academy_flutter/user_reports/user_reports.dart';

final getIt = GetIt.instance;

/// Репозиторий для отправки и получения данных связанных с пользовательскими отчетами
class UserReportsRepository {
  UserReportsRepository();

  /// Отправка запроса к API на получение списка [IndividualReport]
  ///
  /// Список получаю в виде списка,
  /// прохожу по каждому элементу и создаю для каждого новый экземпляр класса
  Future<List<IndividualReport>> fetchIndividualsAttandance(
      {required int individualsPage}) async {
    try {
      final response = await getIt<GraphQLService>().performQuery(
        query.getIndividualsAttendace,
        variables: {'page': individualsPage},
      );

      // Если в теле данных запроса пусто - выбрасывать ошибку
      if (response.data == null) {
        throw Exception();
      }

      // Если нет данных в ответе - пустой список
      if (((response.data?['clientSpace'] as Map<String, dynamic>)['individual']
              as Map<String, dynamic>)['data'] ==
          null) {
        return [];
      }

      final data =
          ((response.data?['clientSpace'] as Map<String, dynamic>)['individual']
              as Map<String, dynamic>)['data'] as List;

      return data.map((dynamic json) {
        final map = json as Map<String, dynamic>;

        // На основе типа задаю заголовок
        final String status;
        switch (map['status'] as String) {
          case 'SUCCEEDED':
            status = 'Посещено';
            break;
          case 'RECORDED':
            status = 'Запись';
            break;
          case 'CANCELED':
            status = 'Отменено';
            break;
          case 'CONFIRMED':
            status = 'Подтверждено';
            break;
          default:
            status = 'Другое';
        }

        return IndividualReport(
          presence: map['presence'] as String,
          status: status,
          // Title может быть null, не знаю почему, но у некоторых пользователей такое случается
          // вопросы к бэку
          title: ((map['subscription']
                      as Map<String, dynamic>)['subscriptionTemplate']
                  as Map<String, dynamic>)['title'] as String? ??
              'Неопознанная индивидуальная тренировка',
          firstName:
              (map['student'] as Map<String, dynamic>)['first_name'] as String,
          middleName:
              (map['student'] as Map<String, dynamic>)['middle_name'] as String,
          lastName:
              (map['student'] as Map<String, dynamic>)['last_name'] as String,
        );
      }).toList();
    } catch (_) {
      rethrow;
    }
  }

  /// Отправка запроса к API на получение списка [PaymentReport]
  ///
  /// Список получаю в виде списка,
  /// прохожу по каждому элементу и создаю для каждого новый экземпляр класса
  Future<List<PaymentReport>> fetchPayments({required int paymentsPage}) async {
    try {
      final response = await getIt<GraphQLService>().performQuery(
        query.getPayments,
        variables: {'page': paymentsPage},
      );

      // Если в теле данных запроса пусто - выбрасывать ошибку
      if (response.data == null) {
        throw Exception();
      }

      // Если нет данных в ответе - пустой список
      if (((response.data?['clientSpace'] as Map<String, dynamic>)['payments']
              as Map<String, dynamic>)['data'] ==
          null) {
        return [];
      }

      final data =
          ((response.data?['clientSpace'] as Map<String, dynamic>)['payments']
              as Map<String, dynamic>)['data'] as List;

      final format = DateFormat('yyyy-MM-dd HH:mm:ss');

      return data.map((dynamic json) {
        final map = json as Map<String, dynamic>;
        // Задаю тип платежа

        String type;

        switch (map['type'] as String) {
          case 'cash':
            type = 'Оплата наличными';
            break;
          case 'online':
            type = 'Оплата онлайн';
            break;
          case 'bank':
            type = 'Банковский перевод';
            break;
          case 'other':
            type = 'Другое';
            break;
          default:
            type = 'Неизвестно';
        }

        // Задаю статус платежа
        String status;
        switch (map['status'] as String) {
          case 'NEW':
            status = 'Создан';
            break;
          case 'FORM_SHOWED':
            status = 'Платежная форма открыта';
            break;
          case 'DEADLINE_EXPIRED':
            status = 'Просрочен';
            break;
          case 'CONFIRMED':
            status = 'Подтвержден';
            break;
          case 'CANCELED':
            status = 'Отменен';
            break;
          case 'REJICTED':
            status = 'Отклонен';
            break;
          case 'AUTHORIZED':
            status = 'Зарезервирован';
            break;
          default:
            status = 'Другое';
        }

        return PaymentReport(
          createdAt: format.parse(map['created_at'] as String),
          status: status,
          amount: map['amount'] as int,
          description: map['description'] as String? ?? 'Оплата',
          name: map['name'] as String? ?? 'Клиент',
          type: type,
        );
      }).toList();
    } catch (_) {
      rethrow;
    }
  }
}
