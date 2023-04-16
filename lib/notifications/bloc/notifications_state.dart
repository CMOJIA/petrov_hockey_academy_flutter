part of 'notifications_bloc.dart';

enum NotificationFetchedStatus { initial, success, failure }

enum NotificationIsReadSatus { initial, inProgress, changed, deleted }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.isReadStatus = NotificationIsReadSatus.initial,
    this.notifications = const <UserNotification>[],
    this.status = NotificationFetchedStatus.initial,
    this.page = 1,
    this.hasReachedMax = false,
  });
  final NotificationIsReadSatus isReadStatus;
  final List<UserNotification> notifications;
  final NotificationFetchedStatus status;
  final int page;
  final bool hasReachedMax;

  NotificationsState copyWith({
    NotificationIsReadSatus? isReadStatus,
    List<UserNotification>? notifications,
    NotificationFetchedStatus? status,
    int? page,
    bool? hasReachedMax,
    int? count,
  }) {
    return NotificationsState(
      isReadStatus: isReadStatus ?? this.isReadStatus,
      notifications: notifications ?? this.notifications,
      status: status ?? this.status,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props =>
      [isReadStatus, notifications, status, page, hasReachedMax];
}
