import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petrov_hockey_academy_flutter/subscriptions/subscriptions.dart';
import 'package:petrov_hockey_academy_flutter/transitions/transitions.dart';

/// Карточка абонемента доступного для покупки
class SubscriptionListItem extends StatelessWidget {
  const SubscriptionListItem({
    super.key,
    required this.index,
    required this.subscription,
    required this.student,
  });

  final SubscriptionTemplate subscription;
  final int index;
  final Student? student;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColorDark,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Title(subscription: subscription),
            _Date(
              subscription: subscription,
            ),
            _Price(subscription: subscription),
            _Button(subscription: subscription, student: student),
          ],
        ),
      ),
    );
  }
}

/// Заголовок карточки абонемента (название абонемента)
class _Title extends StatelessWidget {
  const _Title({required this.subscription});
  final SubscriptionTemplate subscription;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 8,
      ),
      width: double.infinity,
      child: Text(
        // В названии абонемента  могут сожержаться строки: <b>, </b>
        subscription.title.contains('<b>')
            ? subscription.title
                .replaceAll(RegExp(r'</b>|<b>|\(.*?\)'), '')
                .replaceAll('  ', ' ')
            : subscription.title,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Дата на которую покупается абонемент
class _Date extends StatelessWidget {
  const _Date({required this.subscription});
  final SubscriptionTemplate subscription;
  @override
  Widget build(BuildContext context) {
    final _formattedDate = DateFormat('dd.MM.yyyy');
    // Для отображения даты абонемента доступного для покупки только на слеующий месяц
    final _nextMonthDates = '${_formattedDate.format(
      DateTime.utc(
        DateTime.now().year,
        DateTime.now().month + 1,
      ),
    )} - ${_formattedDate.format(
      DateTime.utc(
        DateTime.now().year,
        DateTime.now().month + 2,
        0,
      ),
    )} / По расписанию';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Срок действия: ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            TextSpan(
              // Если сезонный и действующий абонемент заканчивается в этом месяце
              // показываю дату покупки на следующий месяц
              text: subscription.type == 'season'
                  ? subscription.endDt?.month == DateTime.now().month
                      ? _nextMonthDates
                      : subscription.canBuyNextMonth == 1
                          ? _nextMonthDates
                          : '${_formattedDate.format(DateTime.now())} - ${_formattedDate.format(
                              DateTime.utc(
                                DateTime.now().year,
                                DateTime.now().month + 1,
                                0,
                              ),
                            )} / По расписанию'
                  : '30 дней',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}

//// Цена абонемента
class _Price extends StatelessWidget {
  const _Price({required this.subscription});
  final SubscriptionTemplate subscription;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Стоимость: ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            TextSpan(
              text: '${subscription.price} руб.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}

/// Кнопка купить, для перехода к подтверждению параметров покупки абонемента
class _Button extends StatelessWidget {
  const _Button({required this.subscription, required this.student});
  final SubscriptionTemplate subscription;
  final Student? student;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 5,
        right: 5,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            FadeRoute(
              builder: (
                ctx,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
              ) {
                return SubcriptionPaymentScreen(
                    student: student, subscription: subscription);
              },
            ),
          ),
          // Если есть подписка - проверяю дату (дата окончания есть только
          // у сезонных абонементов, переодически  сразу отбросятся)
          // далее проверется тип и на кнопке отображается текст в соответсвии абонементом
          child: Text(
            subscription.subscriptionId != null
                ? subscription.endDt?.month == DateTime.now().month
                    ? 'Продлить'
                    : subscription.type == 'period'
                        ? 'Докупить'
                        : 'Оплатить'
                : 'Оплатить',
            style: const TextStyle(
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
