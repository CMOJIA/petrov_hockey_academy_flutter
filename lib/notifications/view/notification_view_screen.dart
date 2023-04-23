import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petrov_hockey_academy_flutter/app/app.dart';
import 'package:petrov_hockey_academy_flutter/notifications/notifications.dart';

/// Экран просмотра выбранного уведомления
class NotificationViewScreen extends StatelessWidget {
  NotificationViewScreen({required UserNotification notification, super.key})
      : _notification = notification;

  final UserNotification _notification;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BackButton(),
                  _Title(
                    notification: _notification,
                  ),
                  _Content(
                    notification: _notification,
                  )
                ],
              ),
              const Spacer(),
              // Если уведомление о продлении абонемента - покзывать кнопку перехода
              // к странице покупки абонементов
              if (_notification.type == 'Продление абонемента')
                _ToSubscriptionPageButton()
            ],
          ),
        ),
      ),
    );
  }
}

/// Текст уведомления
class _Content extends StatelessWidget {
  const _Content({required this.notification});
  final UserNotification notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
      child: Text(
        '${notification.text}.',
        style: const TextStyle(
          fontSize: 20,
          color: Colors.black54,
        ),
      ),
    );
  }
}

/// Заголовок уведомления
class _Title extends StatelessWidget {
  const _Title({required this.notification});
  final UserNotification notification;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
      child: Text(
        notification.type,
        style: const TextStyle(
          fontSize: 24,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 2,
        overflow: TextOverflow.fade,
        softWrap: true,
      ),
    );
  }
}

/// Кнопка возврата к преыдущему экрану
class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back_ios_rounded,
        ),
        label: Text(
          'Назад',
        ),
      ),
    );
  }
}

/// Если уведомление с напоминанием об окончании срока действия абонемента -
/// кнопка для перехода на страницу абонементов.
class _ToSubscriptionPageButton extends StatelessWidget {
  const _ToSubscriptionPageButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 70, 165, 37),
          ),
          onPressed: () {
            // В будущем реализовать переход к покупке болеее подходящего абонемента для выбранной тренировки
            context.read<AppBloc>().add(const AppSelectedTabsPage(2));
            Navigator.of(context).pop();
          },
          child: Container(
            height: 51,
            padding: const EdgeInsets.all(12),
            child: const Text(
              'На страницу абонементов',
            ),
          ),
        ),
      ),
    );
  }
}
