import 'package:flutter/material.dart';
import 'package:petrov_hockey_academy_flutter/timetables/timetables.dart';
import 'package:intl/intl.dart';

/// Виджет элемента списка дополнительных платных тренировок
class PaidListItem extends StatelessWidget {
  const PaidListItem({super.key, required TrainingPaid trainingPaid})
      : _trainingPaid = trainingPaid;

  final TrainingPaid _trainingPaid;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColorDark,
      elevation: 5,
      child: Column(
        children: [
          _Group(paidGroups: _trainingPaid),
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              top: 8,
              bottom: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DateTime(trainingPaid: _trainingPaid),
                _Area(trainingPaid: _trainingPaid),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Площадка
class _Area extends StatelessWidget {
  const _Area({required this.trainingPaid});
  final TrainingPaid trainingPaid;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 5,
      child: Text.rich(
        TextSpan(text: trainingPaid.area),
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Время тренировки
class _DateTime extends StatelessWidget {
  const _DateTime({required this.trainingPaid});
  final TrainingPaid trainingPaid;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hm();

    return Expanded(
      flex: 3,
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              child: Icon(
                Icons.access_time_rounded,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            TextSpan(
              text:
                  ' ${time.format(trainingPaid.startDt)} - ${time.format(trainingPaid.endDt)}',
            ),
          ],
        ),
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Группа
class _Group extends StatelessWidget {
  const _Group({required this.paidGroups});
  final TrainingPaid paidGroups;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 8,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            paidGroups.group,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
