import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petrov_hockey_academy_flutter/profile_data/profile_data.dart';

enum InputDataType { firstname, middlename, lastname, phoneNumber }

/// Экран с пользовательской информацией, при нажатии на соответствующие данные -
/// появляется ModalBottomSheet с полями ввода для редактирования этих данных
class ProfileDataScreen extends StatelessWidget {
  const ProfileDataScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Аккаунт'),
            Icon(
              Icons.edit_rounded,
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 4),
            // Пользовательские данные разделены на данные профиля и данные аккаунта
            //
            // Профиль
            Card(
              color: Theme.of(context).primaryColorDark,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Заголовок
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      width: double.infinity,
                      child: Text(
                        'Профиль',
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    AvatarEditingButton(),
                    _FirstName(),
                    _LastName(),
                    _MiddleName(),
                  ],
                ),
              ),
            ),
            // Аккаунт
            Card(
              color: Theme.of(context).primaryColorDark,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Заголовок
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      width: double.infinity,
                      child: Text(
                        'Аккаунт',
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    _PhoneNumber(),
                    EmailEditingButton(),
                    PasswordEditingButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Кнопка открытия окна редактирования имени
class _FirstName extends StatelessWidget {
  const _FirstName();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileDataBloc, ProfileDataState>(
      buildWhen: (previous, current) =>
          previous.profileData.firstName != current.profileData.firstName,
      builder: (context, state) {
        return Card(
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            onTap: () => editUserData(
              context,
              'имя',
              InputDataType.firstname,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Имя',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    state.profileData.firstName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Кнопка открытия окна редактирования отчества
class _LastName extends StatelessWidget {
  const _LastName();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileDataBloc, ProfileDataState>(
      buildWhen: (previous, current) =>
          previous.profileData.lastName != current.profileData.lastName,
      builder: (context, state) {
        return Card(
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            onTap: () => editUserData(
              context,
              'отчество',
              InputDataType.lastname,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Отчество',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    state.profileData.lastName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Кнопка открытия окна редактирования фамилии
class _MiddleName extends StatelessWidget {
  const _MiddleName();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileDataBloc, ProfileDataState>(
      buildWhen: (previous, current) =>
          previous.profileData.middleName != current.profileData.middleName,
      builder: (context, state) {
        return Card(
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            onTap: () => editUserData(
              context,
              'фамилию',
              InputDataType.middlename,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Фамилия',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    state.profileData.middleName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Кнопка открытия окна редактирования номера телефона пользователя
class _PhoneNumber extends StatelessWidget {
  const _PhoneNumber();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileDataBloc, ProfileDataState>(
      buildWhen: (previous, current) =>
          previous.profileData.phoneNumber != current.profileData.phoneNumber,
      builder: (context, state) {
        return Card(
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            onTap: () => editUserData(
              context,
              'номер телефона',
              InputDataType.phoneNumber,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Телефон',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    state.profileData.phoneNumber,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
