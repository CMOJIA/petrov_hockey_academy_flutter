import 'package:get_it/get_it.dart';
import 'package:http/http.dart' show MultipartFile;
import 'package:petrov_hockey_academy_flutter/graphQL/graphql_service.dart';
import 'package:petrov_hockey_academy_flutter/graphQL/queries.dart' as query;
import 'package:petrov_hockey_academy_flutter/profile_data/profile_data.dart';

final getIt = GetIt.instance;

/// Репозиторий для отправки и получения данных связанных с пользовательскими данными
class ProfileDataRepository {
  ProfileDataRepository();

  /// Отправка запроса на изменение email
  Future<bool> changeEmail({
    required String email,
  }) async {
    try {
      final response = await getIt<GraphQLService>().performMutation(
        query.setEmail,
        variables: {'email': email},
      );

      return (response.data?['setEmail']);
    } catch (_) {
      rethrow;
    }
  }

  /// Отправка запроса на изменение аватара
  Future<Map<String, dynamic>?> setAvatar({
    required MultipartFile myFile,
  }) async {
    try {
      final response = await getIt<GraphQLService>().performMutation(
        query.setAvatar,
        variables: {
          'file': myFile,
        },
      );

      return (response.data);
    } catch (_) {
      rethrow;
    }
  }

  /// Отправка запроса на получения нового аватара
  Future<Map<String, dynamic>?> getAvatar() async {
    try {
      final avatar = await getIt<GraphQLService>().performQuery(
        query.getAvatar,
        variables: {},
      );

      return (avatar.data);
    } catch (_) {
      rethrow;
    }
  }

  /// Отправка запроса на изменение имени
  Future<bool> changeFirstName({
    required String firstName,
  }) async {
    try {
      final response = await getIt<GraphQLService>().performMutation(
        query.setFirstName,
        variables: {'firstName': firstName},
      );

      return (response.data?['setFirstName']);
    } catch (_) {
      rethrow;
    }
  }

  /// Отправка запроса на изменение фамилии
  Future<bool> changeMiddleName({
    required String middleName,
  }) async {
    try {
      final response = await getIt<GraphQLService>().performMutation(
        query.setMiddleName,
        variables: {'middleName': middleName},
      );

      return (response.data?['setMiddleName']);
    } catch (_) {
      rethrow;
    }
  }

  /// Отправка запроса на изменение отчества
  Future<bool> changeLastName({
    required String lastName,
  }) async {
    try {
      final response = await getIt<GraphQLService>().performMutation(
        query.setLastName,
        variables: {'lastName': lastName},
      );
      return (response.data?['setLastName']);
    } catch (_) {
      rethrow;
    }
  }

  /// Отправка запроса на измененик номера телефона
  Future<bool> changePhoneNumber({
    required String phone,
  }) async {
    try {
      final response = await getIt<GraphQLService>().performMutation(
        query.setPhoneNumber,
        variables: {'phone': '+$phone'},
      );
      return response.data?['setPhone'];
    } catch (_) {
      rethrow;
    }
  }

  /// Отправка запроса к API на получение списка [Group] учеников клиента.
  ///
  /// Перебираю каждый элемент и создаю экземпляр класса [Group]
  Future<List<Group>> getGroups() async {
    try {
      final response = await getIt<GraphQLService>().performQuery(
        query.getGroups,
        variables: {},
      );

      if (response.data == null) {
        return [];
      }

      final data =
          ((response.data?['clientSpace'] as Map<String, dynamic>)['groups']
              as Map<String, dynamic>)['data'] as List;
      return data.map((dynamic json) {
        final map = json as Map<String, dynamic>;

        return Group(
          title: map['title'] as String,
          groupId: map['group_id'] as String,
        );
      }).toList();
    } catch (_) {
      rethrow;
    }
  }

  /// Отправка запроса к API на получение списка [ProfileData]
  Future<ProfileData> getProfileData() async {
    try {
      final response = await getIt<GraphQLService>()
          .performQuery(query.getProfileData, variables: {});

      if (response.data == null) {
        throw Exception();
      }

      final me = (response.data?['clientSpace'] as Map<String, dynamic>)['me']
          as Map<String, dynamic>?;

      // Проверка зарегистрирован ли пользователь, как клиент
      if ((me?['client'] as Map<String, dynamic>?) == null) {
        return ProfileData.empty;
      }

      return ProfileData(
        firstName:
            (me?['client'] as Map<String, dynamic>)['first_name'].toString(),
        middleName:
            (me?['client'] as Map<String, dynamic>)['middle_name'].toString(),
        lastName:
            (me?['client'] as Map<String, dynamic>)['last_name'].toString(),
        photo: (me?['avatar'] as Map<String, dynamic>?) == null
            ? null
            : (me?['avatar'] as Map<String, dynamic>)['filename'].toString(),
        phoneNumber: me?['phone'] as String,
        isRedactor: me?['is_redactor'] as bool,
        email: me?['email'] as String,
      );
    } catch (_) {
      rethrow;
    }
  }
}
