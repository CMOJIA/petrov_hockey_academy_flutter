import 'package:flutter/material.dart';
import 'package:petrov_hockey_academy_flutter/profile_data/profile_data.dart';

// Кнопка открытия окна редактирвания пароля пользователя
class PasswordEditingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        onTap: () => updatePassword(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Пароль',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '●●●●●●●●',
                style: TextStyle(
                  letterSpacing: 2,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
