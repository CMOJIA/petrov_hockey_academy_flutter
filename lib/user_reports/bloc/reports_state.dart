part of 'reports_bloc.dart';

enum ReportsFetchedStatus { initial, success, failure }

class ReportsState extends Equatable {
  const ReportsState({
    this.status = ReportsFetchedStatus.initial,
    this.payments = const <PaymentReport>[],
    this.paymentsPage = 1,
    this.paymentsHasReachedMax = false,
    this.individuals = const <IndividualReport>[],
    this.individualsPage = 1,
    this.individualsHasReachedMax = false,
  });

  final ReportsFetchedStatus status;
  final List<PaymentReport> payments;
  final int paymentsPage;
  final bool paymentsHasReachedMax;
  final List<IndividualReport> individuals;
  final int individualsPage;
  final bool individualsHasReachedMax;

  ReportsState copyWith({
    ReportsFetchedStatus? status,
    List<PaymentReport>? payments,
    int? paymentsPage,
    bool? paymentsHasReachedMax,
    List<IndividualReport>? individualsAttandance,
    int? individualsPage,
    bool? individualsHasReachedMax,
  }) {
    return ReportsState(
      status: status ?? this.status,
      payments: payments ?? this.payments,
      paymentsPage: paymentsPage ?? this.paymentsPage,
      paymentsHasReachedMax:
          paymentsHasReachedMax ?? this.paymentsHasReachedMax,
      individuals: individualsAttandance ?? this.individuals,
      individualsPage: individualsPage ?? this.individualsPage,
      individualsHasReachedMax:
          individualsHasReachedMax ?? this.individualsHasReachedMax,
    );
  }

  @override
  List<Object> get props => [
        status,
        payments,
        paymentsPage,
        paymentsHasReachedMax,
        individuals,
        individualsPage,
        individualsHasReachedMax,
      ];
}
