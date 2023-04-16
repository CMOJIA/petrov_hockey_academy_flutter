import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petrov_hockey_academy_flutter/notifications/notifications.dart';
import 'package:intl/intl.dart';
import 'package:petrov_hockey_academy_flutter/transitions/transitions.dart';

/// Виджет элемента списка уведомлений
class NotificationListItem extends StatelessWidget {
  const NotificationListItem({
    super.key,
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      buildWhen: (previous, current) =>
          previous.isReadStatus != current.isReadStatus,
      builder: (context, state) {
        return Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: InkWell(
            splashColor: Theme.of(context).primaryColor,
            highlightColor: Colors.transparent,
            key: ValueKey(index),
            onTap: () {
              Navigator.push(
                context,
                FadeRoute(
                  builder: (
                    context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                  ) =>
                      NotificationViewScreen(
                    notification: state.notifications[index],
                  ),
                ),
              );
              return context.read<NotificationsBloc>().add(
                    NotificationsIsReaded(
                      notification: state.notifications[index],
                    ),
                  );
            },
            child: Dismissible(
              // Свайп для прочтения уведолмения доступен только для непрочитанных уведомлений
              direction: state.notifications[index].isRead == 1
                  ? DismissDirection.none
                  : DismissDirection.startToEnd,
              background: Container(
                padding: const EdgeInsets.all(20),
                alignment: AlignmentDirectional.centerStart,
                color: Colors.grey,
                child: const Icon(
                  Icons.visibility_off_rounded,
                  color: Colors.white70,
                ),
              ),
              key: UniqueKey(),
              confirmDismiss: (direction) async {
                // Задержка отправления ивента для того, чтобы анимация возвращения возвращения от свайпа успела закончиться
                // т.к. блок перестроит виджет по окончании ивента.
                Future.delayed(const Duration(milliseconds: 300), () {
                  context.read<NotificationsBloc>().add(
                        NotificationsIsReaded(
                          notification: state.notifications[index],
                        ),
                      );
                });
                return null;
              },
              movementDuration: const Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Заголовок
                          _Title(
                            index: index,
                            notifications: state.notifications,
                          ),
                          // Иконка в зависимости от статуса прочтения уведомления
                          _NotificationIcon(
                            index: index,
                            notifications: state.notifications,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // Часть содержимого уведомления и дата его создания
                    _NotificationContent(
                      index: index,
                      notifications: state.notifications,
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    Divider(
                      color:
                          Theme.of(context).primaryColorDark.withOpacity(0.5),
                      thickness: 0.8,
                      height: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Содержимое уведомления: текст и дата создания
class _NotificationContent extends StatelessWidget {
  const _NotificationContent({
    required this.notifications,
    required this.index,
  });
  final List<UserNotification> notifications;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Предпросмотр текста уведомления
        Flexible(
          flex: 5,
          child: Text(
            notifications[index].text,
            style: const TextStyle(
              fontSize: 16,
              overflow: TextOverflow.fade,
              color: Colors.black54,
            ),
            softWrap: false,
          ),
        ),
        // Дата создания
        Flexible(
          flex: 3,
          child: Text(
            DateFormat('dd/MM/yy kk:mm').format(notifications[index].createdDt),
            style: const TextStyle(
              fontSize: 14,
              overflow: TextOverflow.fade,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

/// Иконка уведомления в зависимости от статуса прочтения
class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.notifications, required this.index});
  final List<UserNotification> notifications;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: notifications[index].isRead == 1
          ? const Icon(
              Icons.check_rounded,
              color: Colors.black26,
            )
          : Icon(
              Icons.notification_important_rounded,
              color: Theme.of(context).primaryColor,
            ),
    );
  }
}

/// Заголовок(название) уведомления в зависимости от его типа
class _Title extends StatelessWidget {
  const _Title({required this.notifications, required this.index});
  final List<UserNotification> notifications;
  final int index;
  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 10,
      // Цвет заголовка задается в соответствии с его типом
      child: Text(
        notifications[index].type,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          overflow: TextOverflow.ellipsis,
          color: notifications[index].type == 'Отмена занятия'
              ? Colors.red[900]
              : notifications[index].type == 'Продление абонемента'
                  ? Colors.amber[900]
                  : Colors.black87,
        ),
      ),
    );
  }
}
