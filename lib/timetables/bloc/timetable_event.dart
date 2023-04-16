part of 'timetable_bloc.dart';

abstract class TimetableEvent extends Equatable {
  const TimetableEvent();

  @override
  List<Object> get props => [];
}

class TimetableFetched extends TimetableEvent {}

class TimetableIndividualAttendance extends TimetableEvent {
  const TimetableIndividualAttendance(this.individual, this.studentId);
  final Individual individual;
  final String studentId;
}
