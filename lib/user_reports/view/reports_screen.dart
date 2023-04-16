import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:petrov_hockey_academy_flutter/universal/universal.dart';
import 'package:petrov_hockey_academy_flutter/user_reports/user_reports.dart';
import 'package:petrov_hockey_academy_flutter/transitions/transitions.dart';
import 'package:shimmer/shimmer.dart';

/// Экран со списком категорий отчетов: Тренировки, Оплаты и т.д.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _displaySize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        title: const Text('Мои отчеты'),
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) {
          switch (state.status) {
            case ReportsFetchedStatus.failure:
              return _FailureContent(size: _displaySize);
            case ReportsFetchedStatus.success:
              return _SuccessContent();

            case ReportsFetchedStatus.initial:
              return _ReportsShimmer();
          }
        },
      ),
    );
  }
}

/// Контент когда загрузка данных завершилась успешно
class _SuccessContent extends StatelessWidget {
  const _SuccessContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        _Payments(),
        _Workouts(),
        _IndividualsWorkouts(),
      ],
    );
  }
}

/// Контент когда загрузка данных завершилась ошибкой
class _FailureContent extends StatelessWidget {
  const _FailureContent({required this.size});
  final Size size;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.1,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Ошибка загрузки.\nПроверьте интернет-подключение или повторите попытку позже.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          RefreshButton(
            onTap: () {
              context.read<ReportsBloc>().add(ReportsFetched());
            },
            authenticationRepository: context.read<AuthenticationRepository>(),
          ),
        ],
      ),
    );
  }
}

/// Карточка перехода к отчетам об оплатах
class _Payments extends StatelessWidget {
  const _Payments();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        onTap: () => Navigator.push(
          context,
          FadeRoute(
            builder: (
              ctx,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return BlocProvider.value(
                value: BlocProvider.of<ReportsBloc>(context),
                child: const PaymentsScreen(),
              );
            },
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.payment_rounded,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Text(
                      'Мои оплаты',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Карточка для перехода в отчетам о тренировках
//
// Пока неактивна т.к. бекенд не готов
class _Workouts extends StatelessWidget {
  const _Workouts();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.sports_hockey_rounded,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Text(
                      'Мои тренировки',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Карточка для перехода в отчетам об индивидуальных тренировках
class _IndividualsWorkouts extends StatelessWidget {
  const _IndividualsWorkouts();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        onTap: () => Navigator.push(
          context,
          FadeRoute(
            builder: (
              ctx,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return BlocProvider.value(
                value: BlocProvider.of<ReportsBloc>(context),
                child: const IndividualsScreen(),
              );
            },
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.snowshoeing_rounded,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Text(
                      'Индивидуальные тренировки',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Шиммер при загрузке списка отчетов
class _ReportsShimmer extends StatelessWidget {
  const _ReportsShimmer();

  @override
  Widget build(BuildContext context) {
    final itemHeight = 64.0;
    final color = Colors.grey[400];
    return AbsorbPointer(
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemBuilder: (_, __) => SizedBox(
                  height: itemHeight,
                  width: constraints.maxWidth,
                  child: Shimmer.fromColors(
                    baseColor: color!,
                    highlightColor: Colors.grey[300]!,
                    child: Card(),
                  ),
                ),
                itemCount: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
