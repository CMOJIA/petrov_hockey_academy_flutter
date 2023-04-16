import 'dart:ui';

import 'package:flutter/material.dart';

// Функция отображения диалогового окна с предупреждением, для уведолмения пользователя об ошибке
// или невозможности для него совершить дейтсвие.
Future<void> warningDialog({
  required BuildContext context,
  required String title,
  required String content,
}) {
  return showGeneralDialog<String>(
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
              TextButton.icon(
                // Для закрытия GeneralDialog Navigator.pop(context) не подходит
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.check_rounded,
                  color: Colors.green[600],
                ),
                label: Text(
                  'Ok',
                  style: TextStyle(
                    color: Colors.green[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
