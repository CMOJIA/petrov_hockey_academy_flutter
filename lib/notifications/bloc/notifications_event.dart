part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class NotificationsFetched extends NotificationsEvent {}

class NotificationsLoadedMore extends NotificationsEvent {}

class NotificationsIsReaded extends NotificationsEvent {
  const NotificationsIsReaded({
    required this.notification,
  });

  final UserNotification notification;
}

class NotificationsStatusRefreshed extends NotificationsEvent {}
