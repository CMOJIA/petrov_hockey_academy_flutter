import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:petrov_hockey_academy_flutter/app/bloc/app_bloc.dart';
import 'package:petrov_hockey_academy_flutter/subscriptions/subscriptions.dart';
import 'package:petrov_hockey_academy_flutter/timetables/timetables.dart';
import 'package:petrov_hockey_academy_flutter/transitions/transitions.dart';

/// Виджет элемента списка индивидуальный тренировок выбранного тренера
class IndividualsListItem extends StatelessWidget {
  const IndividualsListItem({super.key, required Individual individual})
      : _individual = individual;

  final Individual _individual;

  @override
  Widget build(BuildContext context) {
    void _showAttendanceDialog({
      required String title,
      required String content,
      required void Function(void) thenFunc,
    }) {
      showGeneralDialog<String>(
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return const SizedBox();
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return Transform.scale(
            scale: anim1.value,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: AlertDialog(
                contentPadding: const EdgeInsets.all(20),
                actionsAlignment: MainAxisAlignment.center,
                title: Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                content: Text(
                  content,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'На страницу оплаты',
                          style: TextStyle(
                            color: Colors.green[600],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.green[600],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ).then(thenFunc);
    }

    return BlocListener<SubscriptionsBloc, SubscriptionsState>(
      listener: (context, state) {
        if (state.attendanceStatus == AttendanceStatus.noSubscription) {
          _showAttendanceDialog(
            content:
                'Для записи на индивидуальную тренировку требуется абонемент. Пожалуйста, купите абонемент и повторите запись.',
            title: 'Требуется абонемент',
            thenFunc: (_) {
              // Переход на старницу оплаты
              context.read<AppBloc>().add(const AppSelectedTabsPage(2));
              Navigator.of(context).maybePop();
            },
          );
        }
      },
      child: BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
        buildWhen: (previous, current) =>
            previous.attendanceStatus != current.attendanceStatus,
        builder: (context, state) {
          // Функция опрееделяющая возможность записи на тренировку, возвразщает bool.
          final _possibleToSignUp =
              _quantityCalc(individuals: _individual, state: state);

          return Card(
            color: Theme.of(context).primaryColorDark,
            elevation: 5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      _DateTime(individuals: _individual),
                      _Area(individuals: _individual),
                    ],
                  ),
                ),
                _AviablePlaces(
                  individuals: _individual,
                ),
                _ToAttendanceScreenButton(
                  possibleToSignUp: _possibleToSignUp,
                  individual: _individual,
                  state: state,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Кнопка перехода к экрану записи на тренировку
class _ToAttendanceScreenButton extends StatelessWidget {
  const _ToAttendanceScreenButton({
    required this.possibleToSignUp,
    required this.individual,
    required this.state,
  });
  final bool possibleToSignUp;
  final Individual individual;
  final SubscriptionsState state;
  @override
  Widget build(BuildContext context) {
    /// Вспомогательный метод для определения подписки которая будет выбрана
    /// для записи.
    void choiseSubscriptionAndTransition({
      required List<SubscriptionTemplate> subscriptions,
      required String regExp,
      required List<Student> students,
    }) {
      for (final element in subscriptions) {
        if (element.subscriptionId != null &&
            element.templateID.contains(
              RegExp(regExp),
            )) {
          // Переход на страницу подтверждения
          Navigator.push(
            context,
            FadeRoute(
              builder: (
                ctx,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
              ) {
                return BlocProvider.value(
                  value: BlocProvider.of<SubscriptionsBloc>(
                    context,
                  ),
                  child: AttendanceScreen(
                    students: students,
                    subscriptionId: element.subscriptionId!,
                    individual: individual,
                  ),
                );
              },
            ),
          );
          break;
        }
        // Если список пройден и у пользователя не нашлось абонемента,
        // который можно применить к записи на тренировку - ставится статус,
        // что у пользователя нет такой подписки и появляется диалоговое окно с предложением
        // перейти на страницу с абонементами доступными для покупки
        else if (element == subscriptions.last) {
          context
              .read<SubscriptionsBloc>()
              .add(SubscriptionsEmptySubscription());
          break;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: possibleToSignUp
          ? ElevatedButton(
              onPressed: individual.limit - individual.attendance.length == 0
                  ? null
                  : () {
                      if (individual.startDt.hour < 12) {
                        choiseSubscriptionAndTransition(
                          subscriptions: state.subscriptionsTemplates,
                          regExp: '11|14|15',
                          students: state.students,
                        );
                      } else if (individual.startDt.hour >= 12) {
                        choiseSubscriptionAndTransition(
                          subscriptions: state.subscriptionsTemplates,
                          regExp: '12|16|17',
                          students: state.students,
                        );
                      }
                    },
              child: const Text(
                'Записаться',
              ),
            )
          : ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 70, 165, 37),
              ),
              child: const Text(
                'Вы уже записаны',
              ),
            ),
    );
  }
}

/// Количество доступных мест для записи
class _AviablePlaces extends StatelessWidget {
  const _AviablePlaces({required this.individuals});
  final Individual individuals;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Свободно мест: ',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          TextSpan(
            text: '${individuals.limit - individuals.attendance.length}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Место проведения тренировки
class _Area extends StatelessWidget {
  const _Area({required this.individuals});
  final Individual individuals;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: individuals.area),
            WidgetSpan(
              child: Icon(
                Icons.place_rounded,
                color: Theme.of(context).primaryColor,
              ),
            )
          ],
        ),
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Дата и время тренировки
class _DateTime extends StatelessWidget {
  const _DateTime({required this.individuals});
  final Individual individuals;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hm();

    return Expanded(
      flex: 2,
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              child: Icon(
                Icons.access_time_rounded,
                color: Theme.of(context).primaryColor,
                size: 18,
              ),
            ),
            TextSpan(
              text:
                  ' ${time.format(individuals.startDt)} - ${time.format(individuals.endDt)}',
            ),
          ],
        ),
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Вспомогательный метод для определения возможности записаться на тренировку.
///
/// Если найдены все ученики пользователя  в данной тренировки - запись становится невозможна
bool _quantityCalc(
    {required SubscriptionsState state, required Individual individuals}) {
  int counter = 0;
  for (final element in state.students) {
    if (individuals.attendance.contains(element.id)) {
      counter++;
      if (counter == state.students.length) break;
    }
  }
  if (counter == state.students.length)
    return false;
  else
    return true;
}
