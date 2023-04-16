import 'package:intl/intl.dart';

import 'package:get_it/get_it.dart';
import 'package:petrov_hockey_academy_flutter/graphQL/graphql_service.dart';
import 'package:petrov_hockey_academy_flutter/graphQL/queries.dart' as query;
import 'package:petrov_hockey_academy_flutter/subscriptions/models/models.dart';

final getIt = GetIt.instance;

/// Репозиторий для отправки и получения данных связанных с абонементами
class SubscriptionsRepository {
  SubscriptionsRepository();

  /// Отправка запроса на запись на тренировку
  Future<int?> attendance({
    required int trainingId,
    required int studentId,
    required int subscriptionId,
  }) async {
    try {
      final response = await getIt<GraphQLService>().performMutation(
        query.attendance,
        variables: {
          'training_id': trainingId,
          'student_id': studentId,
          'subscription_id': subscriptionId,
        },
      );

      return (response.data?['attendance']);
    } catch (_) {
      rethrow;
    }
  }

  /// Отправка запроса к API на получение списка абонементов [SubscriptionTemplate].
  ///
  /// Перебираю каждый элемент и создаю для каждого экземпляр класса.
  Future<List<SubscriptionTemplate>> getSubscriptions() async {
    final response = await getIt<GraphQLService>().performQuery(
      query.getSudscriptionTemplate,
      variables: {},
    );
    try {
      // Если в теле данных запроса пусто - выбрасывать ошибку
      if (response.data == null) {
        throw Exception();
      }

      // Если абонементов нет
      if (((response.data?['clientSpace']
                  as Map<String, dynamic>)['subscriptionTemplate']
              as Map<String, dynamic>)['data'] ==
          null) {
        return [];
      }

      final data = (((response.data?['clientSpace']
                  as Map<String, dynamic>)['subscriptionTemplate']
              as Map<String, dynamic>)['data'] as List)
          .reversed;

      final format = DateFormat('yyyy-MM-dd');

      return data.map((dynamic json) {
        final map = json as Map<String, dynamic>;

        final subscription = map['subscription'] as List;

        // Была ошибка, студенты для которых приобретен конкретный абонемент
        // приходили списком в виде их айди типа int,
        // но при обозначении явно int парсинг json'ки заканичвался ошибкой.
        // Не понятно почему.
        //
        // Пока выход такой, принимаю как dynamic и конвертируюв строку.
        final studString =
            (map['student'] as List).map((e) => e.toString()).toList();

        return SubscriptionTemplate(
          subscriptionId: subscription.isEmpty
              ? null
              : (subscription.first as Map<String, dynamic>)['subscription_id']
                  as String,
          templateID: map['template_id'] as String,
          student: studString,
          title: map['title'] as String,
          description: map['description'] as String,
          price: map['price'] as String,
          canBuyNextMonth: map['canBuyNextMonth'] as int,
          type: map['type'] as String,
          // Не все абонементы являются действующими, поэтому даты у них может не быть
          startDt: subscription.isEmpty ||
                  (subscription.first as Map<String, dynamic>)['start_dt'] ==
                      null
              ? null
              : format.parse(
                  (subscription.first as Map<String, dynamic>)['start_dt']
                      as String,
                ),
          endDt: subscription.isEmpty ||
                  (subscription.first as Map<String, dynamic>)['end_dt'] == null
              ? null
              : format.parse(
                  (subscription.first as Map<String, dynamic>)['end_dt']
                      as String,
                ),
        );
      }).toList();
    } catch (_) {
      rethrow;
    }
  }

  /// Отправка запроса к API на получение списка студентов пользователя [Student]
  ///
  /// Перебираю каждый элемент и создаю для каждого экземпляр класса
  Future<List<Student>> getStudents() async {
    try {
      final response = await getIt<GraphQLService>().performQuery(
        query.getStudents,
        variables: {},
      );

      // Если в теле данных запроса пусто - выбрасывать ошибку
      if (response.data == null) {
        throw Exception();
      }

      // Еслм студентов нет
      if (((response.data?['clientSpace'] as Map<String, dynamic>)['students']
              as Map<String, dynamic>)['data'] ==
          null) {
        return [];
      }

      final data =
          ((response.data?['clientSpace'] as Map<String, dynamic>)['students']
              as Map<String, dynamic>)['data'] as List;

      return data.map((dynamic json) {
        final map = json as Map<String, dynamic>;

        return Student(
          id: map['student_id'] as String,
          firstName: map['first_name'] as String,
          middleName: map['middle_name'] as String,
          lastName: map['last_name'] as String,
        );
      }).toList();
    } catch (_) {
      rethrow;
    }
  }
}
