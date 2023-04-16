import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:petrov_hockey_academy_flutter/repositories/subscriptions_repository.dart';
import 'package:petrov_hockey_academy_flutter/subscriptions/subscriptions.dart';

part 'subscriptions_event.dart';
part 'subscriptions_state.dart';

/// Блок для покупки/продления абонементов на тренировки
class SubscriptionsBloc extends Bloc<SubscriptionsEvent, SubscriptionsState> {
  SubscriptionsBloc({
    required this.httpClient,
  }) : super(const SubscriptionsState()) {
    on<SubscriptionsFetched>(_onSubscriptionsFetched);
    on<SubscriptionsEmptySubscription>(_onNoSubscription);
    on<SubscriptionsAttendance>(_onAttendance);
    on<SubscriptionsSelectedStudentChanged>(_onSelectedStudentChanged);
  }

  final http.Client httpClient;

  final getIt = GetIt.instance;

  final _subscriptionsRepository = SubscriptionsRepository();

  /// Изменение выбираемого студента для отображения доступных для него абонементов
  void _onSelectedStudentChanged(
    SubscriptionsSelectedStudentChanged event,
    Emitter<SubscriptionsState> emit,
  ) {
    return emit(
      state.copyWith(selectedStudentId: event.id),
    );
  }

  /// Отправка запроса для записи на выбранную индивидульную тренировку
  Future<void> _onAttendance(
    SubscriptionsAttendance event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(
      state.copyWith(
        attendanceStatus: AttendanceStatus.inProgress,
      ),
    );

    try {
      final isSuccess = await _subscriptionsRepository.attendance(
        studentId: event.studentId,
        subscriptionId: event.subscriptionId,
        trainingId: event.trainingId,
      );

      // Если в ответе null - произошла ошибка
      if (isSuccess == null) {
        throw Exception();
      }

      // Если в овтете 0 - ученик уже записан
      else if (isSuccess == 0) {
        return emit(
          state.copyWith(
            attendanceStatus: AttendanceStatus.alreadyAttend,
          ),
        );
      } else {
        return emit(
          state.copyWith(
            attendanceStatus: AttendanceStatus.success,
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          attendanceStatus: AttendanceStatus.failure,
        ),
      );
    }
  }

  /// Вызывается у пользвателя нет абонемента, чтобы записаться  на тренировку
  void _onNoSubscription(
    SubscriptionsEmptySubscription event,
    Emitter<SubscriptionsState> emit,
  ) {
    return emit(
      state.copyWith(
        attendanceStatus: AttendanceStatus.noSubscription,
      ),
    );
  }

  /// Вызывается при первоначальной загрузке абонементов [SubscriptionTemplate]
  Future<void> _onSubscriptionsFetched(
    SubscriptionsFetched event,
    Emitter<SubscriptionsState> emit,
  ) async {
    if (state.subscriptionStatus == SubscriptionStatus.initial ||
        state.subscriptionStatus == SubscriptionStatus.failure) {
      final connectivity = await getIt.getAsync<ConnectivityResult>();

      // Проверяю подключено ли устройство к интернету
      // Если статус failure - изменяю на статус initial для отображения шиммера
      if (connectivity == ConnectivityResult.mobile ||
          connectivity == ConnectivityResult.wifi) {
        if (state.subscriptionStatus == SubscriptionStatus.failure) {
          emit(
            state.copyWith(
              subscriptionStatus: SubscriptionStatus.initial,
            ),
          );
        }
      }
    }
    try {
      final subscriptions = await _subscriptionsRepository.getSubscriptions();

      final students = await _subscriptionsRepository.getStudents();

      return emit(
        state.copyWith(
            subscriptionStatus: SubscriptionStatus.success,
            subscriptionsTemplates: subscriptions,
            students: students,
            selectedStudentId: students.first.id),
      );
    } catch (_) {
      emit(
        state.copyWith(
          subscriptionStatus: SubscriptionStatus.failure,
        ),
      );
    }
  }
}
