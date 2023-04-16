import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petrov_hockey_academy_flutter/user_reports/models/payment_report.dart';

/// Элемент списка об оплате.
///
/// По нажатию расширяется вниз, для отображания дополнительного контента.
class PaymentsListItem extends StatefulWidget {
  const PaymentsListItem({
    super.key,
    required PaymentReport payment,
  }) : _payment = payment;

  final PaymentReport _payment;

  @override
  State<PaymentsListItem> createState() => _PaymentsListItemState();
}

class _PaymentsListItemState extends State<PaymentsListItem>
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
              _Title(payment: widget._payment),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Status(payment: widget._payment),
                      const SizedBox(
                        height: 8,
                      ),
                      _DateTime(payment: widget._payment),
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
                  animation: _animation, payment: widget._payment),
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
  const _ExpandingContent({required this.payment, required this.animation});
  final PaymentReport payment;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Сумма оплаты
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Стоимость: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: '${payment.amount} руб.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(
              height: 8,
            ),
            // Тип оплаты
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Способ оплаты: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: payment.type,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(
              height: 8,
            ),
            // Информация о клиенте
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Клиент: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: payment.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}

/// Дата оплаты
class _DateTime extends StatelessWidget {
  const _DateTime({required this.payment});
  final PaymentReport payment;
  @override
  Widget build(BuildContext context) {
    final _formattedDate = DateFormat('dd.MM.yyyy H:mm');

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Дата: ',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          TextSpan(
            text: _formattedDate.format(payment.createdAt),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
      textAlign: TextAlign.start,
    );
  }
}

/// Статус оплаты
class _Status extends StatelessWidget {
  const _Status({required this.payment});
  final PaymentReport payment;

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
            text: payment.status,
            style: payment.status == 'Подтвержден'
                ? TextStyle(fontSize: 18, color: Colors.green)
                : Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
      textAlign: TextAlign.start,
    );
  }
}

/// Заголовок отчета
class _Title extends StatelessWidget {
  const _Title({required this.payment});
  final PaymentReport payment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        // В некоторых оплатах в названии могут содержаться строки: <b>
        payment.description.contains('<b>')
            ? payment.description
                .replaceAll(RegExp(r'</b>|<b>|\(.*?\)'), '')
                .replaceAll('  ', ' ')
            : payment.description,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}
