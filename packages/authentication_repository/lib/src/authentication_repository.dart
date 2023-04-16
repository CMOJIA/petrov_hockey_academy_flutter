import 'dart:async';
import 'dart:convert';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:authentication_repository/graphQL/graphql_service.dart';
import 'package:authentication_repository/graphQL/queries.dart' as query;
import 'package:cache/cache.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SendPasswordResetEmailFailure implements Exception {
  /// {@macro sign_up_with_email_and_password_failure}
  const SendPasswordResetEmailFailure([
    this.message =
        'Ошибка восстановления. Проверьте интернет-подключение или обратитесь в тех. поддержку.',
  ]);

  factory SendPasswordResetEmailFailure.fromCode(String code) {
    switch (code) {
      case 'user-not-found':
        return const SendPasswordResetEmailFailure(
          'Указанные данные отстутсвуют в системе. Проверьте правильность введенных данных!!!',
        );
      default:
        return const SendPasswordResetEmailFailure();
    }
  }

  /// The associated error message.
  final String message;
}

/// {@template log_in_with_email_and_password_failure}
/// Thrown during the login process if a failure occurs.
/// {@endtemplate}
class LogInWithEmailAndPasswordFailure implements Exception {
  /// {@macro log_in_with_email_and_password_failure}
  const LogInWithEmailAndPasswordFailure([
    this.message =
        'Ошибка входа. Проверьте интернет-подключение или обратитесь в тех. поддержку.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory LogInWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'The provided credentials are incorrect.':
        return const LogInWithEmailAndPasswordFailure(
          'Неверный логин или пароль.',
        );
      case 'Email are incorrect.':
        return const LogInWithEmailAndPasswordFailure(
          'Пользователь с таким email не найдем, проверьте правильность ввода или обратитесь в тех. поддержку.',
        );
      case 'user-disabled':
        return const LogInWithEmailAndPasswordFailure(
          'Этот пользователь отключен. Обратитесь в службу поддержки за помощью.',
        );
      case 'user-not-found':
        return const LogInWithEmailAndPasswordFailure(
          'Электронная почта не найдена, пожалуйста, создайте учетную запись.',
        );
      case 'wrong-password':
        return const LogInWithEmailAndPasswordFailure(
          'Неверный пароль, попробуйте еще раз.',
        );
      default:
        return const LogInWithEmailAndPasswordFailure();
    }
  }

  /// The associated error message.
  final String message;
}

/// {@template authentication_repository}
/// Repository which manages user authentication.
/// {@endtemplate}
class AuthenticationRepository {
  static const storage = FlutterSecureStorage();

  /// {@macro authentication_repository}
  AuthenticationRepository({
    CacheClient? cache,
    GraphQLService? service,
  })  : _cache = cache ?? CacheClient(),
        _service = service ?? GraphQLService();

  final CacheClient _cache;
  final GraphQLService _service;

  ///контроллер стрима
  final controller = StreamController<User>();

  /// Stream of [User.empty] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> get user {
    return controller.stream;
  }

  /// Returns the current cached user.
  /// Defaults to [User.empty] if there is no cached user.
  User get currentUser {
    return _cache.read<User>(key: '__user_cache_key__') ?? User.empty;
  }

  /// Creates a new user with the provided [email].
  ///
  /// Throws a [SendPasswordResetEmailFailure] if an exception occurs.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      final result = await _service.performQuery(
        query.passRestore,
        variables: {
          'email': email,
        },
      );

      if (result.exception?.linkException != null) {
        throw const SendPasswordResetEmailFailure();
      } else if ((result.data?['commonSpace']
              as Map<String, dynamic>)['passRestore'] ==
          'false') {
        throw SendPasswordResetEmailFailure.fromCode('user-not-found');
      } else {
        const SendPasswordResetEmailFailure();
      }
    } catch (_) {
      rethrow;
    }
  }

  /// Локальное обновление почты
  Future<void> updateEmail({
    required String email,
  }) async {
    final userData = json.encode({
      'token': currentUser.token,
      'id': currentUser.id,
      'email': email,
      'username': currentUser.username,
    });
    await storage.write(key: 'userData', value: userData);
    _cache.write(
      key: '__user_cache_key__',
      value: User(
        token: currentUser.token,
        id: currentUser.id,
        username: currentUser.username,
      ),
    );
  }

  /// Попытка автологина при запуске приложения
  Future<void> tryAutoLogin() async {
    // Если не содержат ключа сохраненные данные то возвращаю в стрим пустого пользователя
    if (!(await storage.containsKey(key: 'userData'))) {
      return;
    }
    // Иначе получаю данные по ключу
    //
    // json.decode не может принимать потенциально null-вые значение, потому была ошибка
    // решил с пметодом toString()
    final extractedUserData =
        json.decode((await storage.read(key: 'userData')).toString())
            as Map<String, dynamic>;
    _cache.write(
      key: '__user_cache_key__',
      value: User(
        token: extractedUserData['token'] as String,
        id: extractedUserData['id'] as String,
        username: extractedUserData['username'] as String,
      ),
    );
  }

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _service.performMutation(
        query.logIn,
        variables: {
          'email': email,
          'password': password,
        },
      );
      if (result.hasException) {
        // if (result.exception?.linkException != null) {}
        if (result.exception!.graphqlErrors.isNotEmpty) {
          throw LogInWithEmailAndPasswordFailure.fromCode('user-not-found');
        } else {
          throw const LogInWithEmailAndPasswordFailure();
        }
      } else if ((result.data?['login'] as Map<String, dynamic>)['token']
              as String ==
          'The provided credentials are incorrect.') {
        throw LogInWithEmailAndPasswordFailure.fromCode(
          (result.data?['login'] as Map<String, dynamic>)['token'].toString(),
        );
      }
      final loginToken =
          (result.data?['login'] as Map<String, dynamic>)['token'] as String;
      final loginUser = (result.data?['login'] as Map<String, dynamic>)['user']
          as Map<String, dynamic>;
      final user = User(
        token: loginToken,
        id: loginUser['id'] as String,
        username: loginUser['username'] as String,
      );
      _cache.write(key: '__user_cache_key__', value: user);
      final userData = json.encode({
        'token': loginToken,
        'id': loginUser['id'] as String,
        'username': loginUser['username'] as String,
      });
      controller.add(user);
      await storage.write(key: 'userData', value: userData);
    } catch (_) {
      rethrow;
    }
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  Future<void> logOut() async {
    _cache.write(key: '__user_cache_key__', value: User.empty);
    await storage.deleteAll();
    controller.add(User.empty);
  }
}
