import 'package:equatable/equatable.dart';

/// {@template user}
/// User model
///
/// [User.empty] represents an unauthenticated user.
/// {@endtemplate}
class User extends Equatable {
  /// {@macro user}
  const User({
    required this.token,
    required this.id,
    this.username,
  });

  ///The current user's token.
  final String token;

  /// The current user's id.
  final String id;

  /// The current user's name (display name).
  final String? username;

  /// Url for the current user's photo.

  /// Empty user which represents an unauthenticated user.
  static const empty = User(token: '', id: '');

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == User.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != User.empty;

  @override
  List<Object?> get props => [token, id, username];
}
