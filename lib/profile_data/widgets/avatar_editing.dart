import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petrov_hockey_academy_flutter/profile_data/profile_data.dart';

/// Кнопка открытия окна редактирования аватара пользователя
class AvatarEditingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileDataBloc, ProfileDataState>(
      buildWhen: (previous, current) =>
          previous.profileData.photo != current.profileData.photo,
      builder: (context, state) {
        return Card(
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            onTap: () => imagePicker(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Изменить аватар',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (state.profileData.photo == null)
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey,
                      foregroundImage: AssetImage(
                        'assets/empty_avatar.png',
                      ),
                    )
                  else
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.transparent,
                      foregroundImage: state.profileData.photo == null
                          ? null
                          : NetworkImage(
                              'https://hb.bizmrg.com/st.test.petrovacademy.ru/avatars/${state.profileData.photo}',
                            ),
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
