import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:petrov_hockey_academy_flutter/repositories/timetables_repository.dart';
import 'package:petrov_hockey_academy_flutter/timetables/timetables.dart';

part 'timetable_event.dart';
part 'timetable_state.dart';

/// Блок для просмотра пользователем расписания тренировок
class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  TimetableBloc() : super(const TimetableState()) {
    on<TimetableFetched>(_onTimetableFetched);
    on<TimetableIndividualAttendance>(
      _onIndividualAttendance,
    );
  }

  final getIt = GetIt.instance;

  final _timetableRepository = TimetableRepository();

  /// Вызывается после записи на индивидуальную тренировку.
  ///
  /// Добавляю записанного студента в список студентов этой тренировки(локально в приложении),
  /// чтобы было информарование о том, что на данную тренировку студент уже записан
  void _onIndividualAttendance(
    TimetableIndividualAttendance event,
    Emitter<TimetableState> emit,
  ) {
    final newItem = event.individual.copyWith(
        attendance: event.individual.attendance..add(event.studentId));

    final individalIndex = state.individuals.indexWhere(
      (element) => element.trainingId == newItem.trainingId,
    );

    emit(
      state.copyWith(
        attendanceStatus: TimeTableAttendanceStatus.initial,
      ),
    );

    // Если  тренировка нашлась в списке тренировок
    if (individalIndex >= 0) {
      state.individuals[individalIndex] = newItem;
      return emit(
        state.copyWith(attendanceStatus: TimeTableAttendanceStatus.changed),
      );
    }
  }

  /// Получение списка тренировок.
  ///
  /// Вызывается при первоначальной загрузке тренировок
  /// [TrainingFree] & [TrainingPaid] & [Individual]
  Future<void> _onTimetableFetched(
    TimetableFetched event,
    Emitter<TimetableState> emit,
  ) async {
    if (state.status == TimeTableStatus.initial ||
        state.status == TimeTableStatus.failure) {
      final connectivity = await getIt.getAsync<ConnectivityResult>();

      // Проверяю подключено ли устройство к интернету
      // Если статус failure - изменяю на статус initial для отображения шиммера
      if (connectivity == ConnectivityResult.mobile ||
          connectivity == ConnectivityResult.wifi) {
        if (state.status == TimeTableStatus.failure) {
          emit(
            state.copyWith(
              status: TimeTableStatus.initial,
            ),
          );
        }
      }
    }
    try {
      final trainingsFree = await _timetableRepository.fetchTrainingsFree();

      final trainingsPaid = await _timetableRepository.fetchTrainingsPaid();

      final individuals = await _timetableRepository.fetchTrainingsIndividual();

      final coaches = <Coach>[];

      for (final e in individuals) {
        if (!coaches.contains(e.coach)) coaches.add(e.coach);
      }

      return emit(
        state.copyWith(
          status: TimeTableStatus.success,
          trainingsFree: trainingsFree,
          trainingsPaid: trainingsPaid,
          individuals: individuals,
          coaches: coaches,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: TimeTableStatus.failure));
    }
  }
}
