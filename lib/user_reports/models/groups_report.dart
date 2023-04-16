import 'package:equatable/equatable.dart';
import 'package:petrov_hockey_academy_flutter/user_reports/models/coach.dart';

class GroupReport extends Equatable {
  const GroupReport({
    required this.presence,
    required this.studentId,
    required this.group,
    required this.area,
    required this.startDt,
    required this.coach,
  });

  final int presence;

  final int studentId;

  final String group;

  final String area;

  final String startDt;

  final List<Coach> coach;

  @override
  List<Object> get props => [presence, studentId, group, area, startDt, coach];
}
