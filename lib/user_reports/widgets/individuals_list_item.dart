import 'package:flutter/material.dart';
import 'package:petrov_hockey_academy_flutter/user_reports/models/individuals_report.dart';

/// Элемент списка об индивидуальной тренировке.
///
/// По нажатию расширяется вниз, для отображания дополнительного контента.
class IndividualsReportsListItem extends StatefulWidget {
  const IndividualsReportsListItem({
    super.key,
    required IndividualReport individualReport,
  }) : _individualReport = individualReport;

  final IndividualReport _individualReport;

  @override
  State<IndividualsReportsListItem> createState() =>
      _IndividualsReportsListItemState();
}

class _IndividualsReportsListItemState extends State<IndividualsReportsListItem>
    with TickerProviderStateMixin {
  var _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: UniqueKey(),
      child: Card(
        color: Theme.of(context).primaryColorDark,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Student(individualReport: widget._individualReport),
                      const SizedBox(
                        height: 8,
                      ),
                      _Status(individualReport: widget._individualReport),
                      const SizedBox(
                        height: 8,
                      ),
                      _Presence(individualReport: widget._individualReport),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: RotationTransition(
                      turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
                      child: Icon(
                        Icons.expand_less_rounded,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
              _ExpandingContent(
                animation: _animation,
                individualReport: widget._individualReport,
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        setState(() {
          if (_expanded) {
            _controller.animateBack(0, duration: Duration(milliseconds: 300));
          } else {
            _controller.forward(from: 0);
          }
          _expanded = !_expanded;
        });
      },
    );
  }
}

/// Контент который появялется  при расширении элемента списка
class _ExpandingContent extends StatelessWidget {
  const _ExpandingContent({
    required this.animation,
    required this.individualReport,
  });
  final Animation<double> animation;
  final IndividualReport individualReport;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.vertical,
      child:
          // Элемент списка отчета об индивидуальных тренировках
          Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Абонемент: ',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextSpan(
                // В некоторых отчетах в названии могут содержаться строки: <b>
                text: individualReport.title.contains('<b>')
                    ? individualReport.title
                        .replaceAll(
                          RegExp(r'</b>|<b>|\(.*?\)'),
                          '',
                        )
                        .replaceAll('  ', ' ')
                    : individualReport.title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          textAlign: TextAlign.start,
        ),
      ),
    );
  }
}

/// Статус посещаемости данной тренировки
class _Presence extends StatelessWidget {
  const _Presence({required this.individualReport});
  final IndividualReport individualReport;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Посещаемость: ',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          TextSpan(
            text: individualReport.presence == '1' ? 'Был' : 'Не был',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
      textAlign: TextAlign.start,
    );
  }
}

/// Статус посещаемости данной тренировки
class _Status extends StatelessWidget {
  const _Status({required this.individualReport});
  final IndividualReport individualReport;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Статус: ',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          TextSpan(
            text: individualReport.status,
            style: individualReport.status == 'Посещено'
                ? TextStyle(fontSize: 18, color: Colors.green)
                : Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
      textAlign: TextAlign.start,
    );
  }
}

/// ФИО ученика
class _Student extends StatelessWidget {
  const _Student({required this.individualReport});
  final IndividualReport individualReport;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Ученик: ',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          TextSpan(
            text: '''${individualReport.middleName} '''
                '''${individualReport.firstName.substring(0, 1).toUpperCase()}.'''
                '''${individualReport.lastName.substring(0, 1).toUpperCase()}.''',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
      textAlign: TextAlign.start,
    );
  }
}
