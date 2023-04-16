part of 'timetable_bloc.dart';

enum TimeTableStatus { initial, success, failure }

enum TimeTableAttendanceStatus { initial, changed }

class TimetableState extends Equatable {
  const TimetableState({
    this.status = TimeTableStatus.initial,
    this.attendanceStatus = TimeTableAttendanceStatus.initial,
    this.trainingsPaid = const <TrainingPaid>[],
    this.trainingsFree = const <TrainingFree>[],
    this.coaches = const <Coach>[],
    this.individuals = const <Individual>[],
  });

  final TimeTableStatus status;
  final TimeTableAttendanceStatus attendanceStatus;
  final List<TrainingPaid> trainingsPaid;
  final List<TrainingFree> trainingsFree;
  final List<Coach> coaches;
  final List<Individual> individuals;

  TimetableState copyWith({
    TimeTableStatus? status,
    TimeTableAttendanceStatus? attendanceStatus,
    List<TrainingPaid>? trainingsPaid,
    List<TrainingFree>? trainingsFree,
    List<Coach>? coaches,
    List<Individual>? individuals,
    int? page,
    int? selectedTabPage,
  }) {
    return TimetableState(
      status: status ?? this.status,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      trainingsPaid: trainingsPaid ?? this.trainingsPaid,
      trainingsFree: trainingsFree ?? this.trainingsFree,
      coaches: coaches ?? this.coaches,
      individuals: individuals ?? this.individuals,
    );
  }

  @override
  List<Object> get props => [
        status,
        attendanceStatus,
        trainingsFree,
        trainingsPaid,
        coaches,
        individuals,
      ];
}
