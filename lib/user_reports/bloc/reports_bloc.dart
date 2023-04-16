import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:petrov_hockey_academy_flutter/repositories/user_reports_repository.dart';
import 'package:petrov_hockey_academy_flutter/user_reports/user_reports.dart';

part 'reports_event.dart';
part 'reports_state.dart';

/// Блок для просмотра отчетов пользователя
///
/// [ReportsBloc] имеет зависимость от [AuthenticationRepository] для отправки запросов,
/// требующих токен пользователя
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  ReportsBloc({
    required this.httpClient,
    required AuthenticationRepository authenticationRepository,
  }) : super(const ReportsState()) {
    on<ReportsFetched>(_onReportsFetched);
    on<ReportsPaymentsLoadedMore>(
      _onPaymentsLoadedMore,
      transformer: droppable(),
    );
    on<ReportsIndividualsLoadedMore>(
      _onIndividualsLoadedMore,
      transformer: droppable(),
    );
  }

  final http.Client httpClient;

  final getIt = GetIt.instance;

  final _userReportsRepository = UserReportsRepository();

  Duration throttleDuration = const Duration(milliseconds: 100);

  /// Загрузка следующей страницы списка отчетов об оплатах
  Future<void> _onPaymentsLoadedMore(
    ReportsPaymentsLoadedMore event,
    Emitter<ReportsState> emit,
  ) async {
    if (state.paymentsHasReachedMax) return;

    try {
      final payments = await _userReportsRepository.fetchPayments(
          paymentsPage: state.paymentsPage);

      return emit(
        state.copyWith(
          payments: List.of(state.payments)..addAll(payments),
          paymentsPage: state.paymentsPage + 1,
          paymentsHasReachedMax: payments.length < 20,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ReportsFetchedStatus.failure,
        ),
      );
    }
  }

  /// Загрузка следующей страницы списка отчетов об индивидуальных тренировках
  Future<void> _onIndividualsLoadedMore(
    ReportsIndividualsLoadedMore event,
    Emitter<ReportsState> emit,
  ) async {
    if (state.individualsHasReachedMax) return;

    try {
      final individuals = await _userReportsRepository
          .fetchIndividualsAttandance(individualsPage: state.individualsPage);

      return emit(
        state.copyWith(
          individualsAttandance: List.of(state.individuals)
            ..addAll(individuals),
          individualsPage: state.individualsPage + 1,
          individualsHasReachedMax: individuals.length < 20,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ReportsFetchedStatus.failure,
        ),
      );
    }
  }

  /// Вызывается при первоначальной загрузке отчетов [PaymentReport] & [IndividualReport]
  Future<void> _onReportsFetched(
    ReportsFetched event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      if (state.status == ReportsFetchedStatus.initial ||
          state.status == ReportsFetchedStatus.failure) {
        final connectivity = await getIt.getAsync<ConnectivityResult>();

        // Проверяю подключено ли устройство к интернету
        // Если статус failure - изменяю на статус initial для отображения шиммера
        if (connectivity == ConnectivityResult.mobile ||
            connectivity == ConnectivityResult.wifi) {
          if (state.status == ReportsFetchedStatus.failure) {
            emit(
              state.copyWith(
                status: ReportsFetchedStatus.initial,
              ),
            );
          }
        }

        final payments = await _userReportsRepository.fetchPayments(
            paymentsPage: state.paymentsPage);

        final individualsAttandance = await _userReportsRepository
            .fetchIndividualsAttandance(individualsPage: state.individualsPage);

        return emit(
          state.copyWith(
            status: ReportsFetchedStatus.success,
            payments: payments,
            paymentsPage: state.paymentsPage + 1,
            paymentsHasReachedMax: payments.length < 20,
            individualsAttandance: individualsAttandance,
            individualsPage: state.individualsPage + 1,
            individualsHasReachedMax: individualsAttandance.length < 20,
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          status: ReportsFetchedStatus.failure,
        ),
      );
    }
  }
}
