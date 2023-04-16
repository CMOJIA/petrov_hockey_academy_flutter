import 'package:flutter/material.dart';
import 'package:petrov_hockey_academy_flutter/timetables/timetables.dart';
import 'package:intl/intl.dart';

/// Виджет элемента списка бюджетных платных тренировок
class FreeListItem extends StatelessWidget {
  const FreeListItem({super.key, required this.trainingsFree});

  final TrainingFree trainingsFree;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColorDark,
      elevation: 2,
      child: Column(
        children: [
          _GroupTitle(
            trainingsFree: trainingsFree,
          ),
          _ListItemContent(
            trainingsFree: trainingsFree,
          )
        ],
      ),
    );
  }
}

/// Дата и место проведения
class _ListItemContent extends StatelessWidget {
  const _ListItemContent({required this.trainingsFree});
  final TrainingFree trainingsFree;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hm();

    return Padding(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Дата
          Expanded(
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
                        ' ${time.format(trainingsFree.startDt)} - ${time.format(trainingsFree.endDt)}',
                  ),
                ],
              ),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          // Место
          Expanded(
            flex: 5,
            child: Text.rich(
              TextSpan(text: trainingsFree.area),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Группа
class _GroupTitle extends StatelessWidget {
  const _GroupTitle({required this.trainingsFree});
  final TrainingFree trainingsFree;

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
            trainingsFree.group,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
