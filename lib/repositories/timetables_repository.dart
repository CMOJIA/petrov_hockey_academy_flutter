import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

import 'package:get_it/get_it.dart';
import 'package:petrov_hockey_academy_flutter/graphQL/graphql_service.dart';
import 'package:authentication_repository/graphQL/queries.dart' as query;
import 'package:petrov_hockey_academy_flutter/timetables/models/models.dart';

final getIt = GetIt.instance;

/// Репозиторий для отправки и получения данных связанных расписанием
class TimetableRepository {
  TimetableRepository();

  /// Отправка запроса на получение списка [TrainingFree]
  Future<List<TrainingFree>> fetchTrainingsFree() async {
    try {
      final response = await getIt<GraphQLService>().performQuery(
        query.getTrainingsFree,
        variables: {
          'from': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'to': DateFormat('yyyy-MM-dd')
              .format(DateTime.now().add(const Duration(days: 14))),
        },
      );

      // Парсинг в изояте
      return compute(_toTrainigsFree, response);
    } catch (_) {
      rethrow;
    }
  }

  /// Отправка запроса на получение списка [TrainingPaid]
  Future<List<TrainingPaid>> fetchTrainingsPaid() async {
    try {
      final response = await getIt<GraphQLService>().performQuery(
        query.getTrainingsPaid,
        variables: {
          'from': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'to': DateFormat('yyyy-MM-dd')
              .format(DateTime.now().add(const Duration(days: 14))),
        },
      );

      // Парсинг в изоляте
      return compute(_toTrainingsPaid, response);
    } catch (_) {
      rethrow;
    }
  }

  /// Отправка запроса на получение списка [Individual]
  Future<List<Individual>> fetchTrainingsIndividual() async {
    try {
      final response = await getIt<GraphQLService>().performQuery(
        query.getIndividuals,
        variables: {
          'from': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'to': DateFormat('yyyy-MM-dd')
              .format(DateTime.now().add(const Duration(days: 14))),
        },
      );

      // парсинг в изоляте
      return compute(_toIndividual, response);
    } catch (_) {
      rethrow;
    }
  }

  /// Парсинг json в список [TrainingFree]
  /// Список [TrainingFree] получаю в виде списка,
  /// перебираю каждый элемент и создаю для каждого экземпляр класса
  List<TrainingFree> _toTrainigsFree(QueryResult queryResult) {
    try {
      // Если в теле данных запроса пусто - выбрасывать ошибку
      if (queryResult.hasException) {
        throw Exception();
      }

      // Если тренировок нет
      if (((queryResult.data?['commonSpace']
                  as Map<String, dynamic>)['trainingsFree']
              as Map<String, dynamic>)['data'] ==
          null) {
        return [];
      }

      final data = ((queryResult.data?['commonSpace']
              as Map<String, dynamic>)['trainingsFree']
          as Map<String, dynamic>)['data'] as List;

      final format = DateFormat('yyyy-MM-dd HH:mm:ss');

      return data.map((dynamic json) {
        final map = json as Map<String, dynamic>;

        return TrainingFree(
          startDt: format.parse(map['start_dt'] as String),
          endDt: format.parse(map['end_dt'] as String),
          area: (map['area'] as Map<String, dynamic>)['name'] as String,
          group: (map['group'] as Map<String, dynamic>)['title'] as String,
        );
      }).toList();
    } catch (_) {
      rethrow;
    }
  }

  /// Парсинг json в список [TrainingPaid]
  /// Список [TrainingPaid] получаю в виде списка,
  /// прохожу по каждому элементу и создаю для каждого новый экземпляр класса
  List<TrainingPaid> _toTrainingsPaid(QueryResult queryResult) {
    try {
      // Если в теле данных запроса пусто - выбрасывать ошибку
      if (queryResult.hasException) {
        throw Exception();
      }

      // Если тренировок нет
      if (((queryResult.data?['commonSpace']
                  as Map<String, dynamic>)['trainingsPaid']
              as Map<String, dynamic>)['data'] ==
          null) {
        return [];
      }

      final data = ((queryResult.data?['commonSpace']
              as Map<String, dynamic>)['trainingsPaid']
          as Map<String, dynamic>)['data'] as List;

      final format = DateFormat('yyyy-MM-dd HH:mm:ss');

      return data.map((dynamic json) {
        final map = json as Map<String, dynamic>;

        return TrainingPaid(
          startDt: format.parse(map['start_dt'] as String),
          endDt: format.parse(map['end_dt'] as String),
          area: (map['area'] as Map<String, dynamic>)['name'] as String,
          group: (map['group'] as Map<String, dynamic>)['title'] as String,
        );
      }).toList();
    } catch (_) {
      rethrow;
    }
  }

  /// Парсинг json в список [Individual]
  /// Список [Individual] получаю в виде списка,
  /// прохожу по каждому элементу и создаю для каждого новый экземпляр класса
  List<Individual> _toIndividual(QueryResult queryResult) {
    try {
      // Если в теле данных запроса пусто - выбрасывать ошибку
      if (queryResult.hasException) {
        throw Exception();
      }

      // Если тренировок нет
      if (((queryResult.data?['commonSpace']
                  as Map<String, dynamic>)['trainingsIndividual']
              as Map<String, dynamic>)['data'] ==
          null) {
        return [];
      }

      final data = ((queryResult.data?['commonSpace']
              as Map<String, dynamic>)['trainingsIndividual']
          as Map<String, dynamic>)['data'] as List;

      final format = DateFormat('yyyy-MM-dd HH:mm:ss');

      return data.map((dynamic json) {
        final map = json as Map<String, dynamic>;

        final coach = map['coach'] as Map<String, dynamic>;

        final attendance = map['attendance'] as List;
        return Individual(
          startDt: format.parse(map['start_dt'] as String),
          endDt: format.parse(map['end_dt'] as String),
          area: (map['area'] as Map<String, dynamic>)['name'] as String,
          limit: map['limit'] as int,
          trainingId: map['training_id'] as String,
          coach: Coach(
            coachId: coach['coach_id'] as String,
            firstName: coach['first_name'] as String,
            lastName: coach['last_name'] as String,
            middleName: coach['middle_name'] as String,
            path: coach['path'] as String,
            photo: coach['photo'] ?? null,
            position: coach['position'] as String,
          ),
          attendance: attendance.map((dynamic e) {
            return e['student_id'].toString();
          }).toList(),
        );
      }).toList();
    } catch (_) {
      rethrow;
    }
  }
}
