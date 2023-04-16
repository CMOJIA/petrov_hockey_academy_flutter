import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petrov_hockey_academy_flutter/profile_data/profile_data.dart';

// Кнопка открытия окна редактирвания email пользователя
class EmailEditingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileDataBloc, ProfileDataState>(
      buildWhen: (previous, current) =>
          previous.profileData.email != current.profileData.email,
      builder: (context, state) {
        return Card(
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            onTap: () => updateEmail(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'e-mail',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    state.profileData.email,
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
