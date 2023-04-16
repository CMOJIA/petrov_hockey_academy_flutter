import 'package:equatable/equatable.dart';

class UserNotification extends Equatable {
  const UserNotification({
    required this.id,
    required this.createdDt,
    required this.type,
    required this.text,
    required this.isRead,
  });

  final String id;

  final DateTime createdDt;

  final String type;

  final String text;

  final int isRead;

  UserNotification copyWith({
    String? id,
    DateTime? createdDt,
    String? type,
    String? text,
    int? isRead,
  }) {
    return UserNotification(
      id: id ?? this.id,
      createdDt: createdDt ?? this.createdDt,
      type: type ?? this.type,
      text: text ?? this.text,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object> get props => [id, createdDt, type, text, isRead];
}
