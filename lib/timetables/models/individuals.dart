import 'package:equatable/equatable.dart';
import 'package:petrov_hockey_academy_flutter/timetables/timetables.dart';

class Individual extends Equatable {
  const Individual({
    required this.startDt,
    required this.endDt,
    required this.area,
    required this.limit,
    required this.trainingId,
    required this.coach,
    required this.attendance,
  });

  final DateTime startDt;

  final DateTime endDt;

  final String area;

  final int limit;

  final String trainingId;

  final Coach coach;

  final List<String> attendance;

  Individual copyWith({
    DateTime? startDt,
    DateTime? endDt,
    String? area,
    int? limit,
    String? trainingId,
    Coach? coach,
    List<String>? attendance,
  }) {
    return Individual(
      startDt: startDt ?? this.startDt,
      endDt: endDt ?? this.endDt,
      area: area ?? this.area,
      limit: limit ?? this.limit,
      trainingId: trainingId ?? this.trainingId,
      coach: coach ?? this.coach,
      attendance: attendance ?? this.attendance,
    );
  }

  @override
  List<Object> get props =>
      [startDt, endDt, area, limit, trainingId, coach, attendance];
}
