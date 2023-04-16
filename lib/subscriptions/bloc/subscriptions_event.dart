part of 'subscriptions_bloc.dart';

abstract class SubscriptionsEvent extends Equatable {
  const SubscriptionsEvent();

  @override
  List<Object> get props => [];
}

class SubscriptionsFetched extends SubscriptionsEvent {}

class SubscriptionsEmptySubscription extends SubscriptionsEvent {}

class SubscriptionsAttendance extends SubscriptionsEvent {
  const SubscriptionsAttendance({
    required this.trainingId,
    required this.studentId,
    required this.subscriptionId,
  });
  final int trainingId;
  final int studentId;
  final int subscriptionId;
}

class SubscriptionsSelectedStudentChanged extends SubscriptionsEvent {
  const SubscriptionsSelectedStudentChanged(this.id);
  final String id;
}
