import 'package:equatable/equatable.dart';

class TrainingFree extends Equatable {
  const TrainingFree({
    required this.startDt,
    required this.endDt,
    required this.area,
    required this.group,
  });

  final DateTime startDt;

  final DateTime endDt;

  final String area;

  final String group;

  @override
  List<Object> get props => [startDt, endDt, area, group];
}
