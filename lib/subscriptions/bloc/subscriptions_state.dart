part of 'subscriptions_bloc.dart';

enum SubscriptionStatus { initial, success, failure }

enum AttendanceStatus {
  initial,
  success,
  failure,
  inProgress,
  noSubscription,
  alreadyAttend
}

class SubscriptionsState extends Equatable {
  const SubscriptionsState({
    this.subscriptionStatus = SubscriptionStatus.initial,
    this.attendanceStatus = AttendanceStatus.initial,
    this.subscriptionsTemplates = const <SubscriptionTemplate>[],
    this.students = const <Student>[],
    this.selectedStudentId = '',
  });

  final SubscriptionStatus subscriptionStatus;
  final AttendanceStatus attendanceStatus;
  final List<SubscriptionTemplate> subscriptionsTemplates;
  final List<Student> students;
  final String selectedStudentId;

  SubscriptionsState copyWith({
    SubscriptionStatus? subscriptionStatus,
    AttendanceStatus? attendanceStatus,
    List<SubscriptionTemplate>? subscriptionsTemplates,
    List<Student>? students,
    String? selectedStudentId,
  }) {
    return SubscriptionsState(
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      subscriptionsTemplates:
          subscriptionsTemplates ?? this.subscriptionsTemplates,
      students: students ?? this.students,
      selectedStudentId: selectedStudentId ?? this.selectedStudentId,
    );
  }

  @override
  List<Object> get props => [
        subscriptionStatus,
        attendanceStatus,
        subscriptionsTemplates,
        students,
        selectedStudentId
      ];
}
