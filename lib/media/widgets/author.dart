import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../profile_data/bloc/profile_data_bloc.dart';

/// Универсальный [Text] виджет с ФИО автора альбома/видео
class Author extends StatelessWidget {
  const Author();

  @override
  Widget build(BuildContext context) {
    final stateProfileData = context.watch<ProfileDataBloc>().state;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Автор:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 20,
            ),
          ),
          Expanded(
            child: Text(
              '''${stateProfileData.profileData.middleName} '''
              '''${stateProfileData.profileData.firstName.substring(0, 1).toUpperCase()}.'''
              '''${stateProfileData.profileData.lastName.substring(0, 1).toUpperCase()}.''',
              textAlign: TextAlign.end,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 24,
                shadows: const [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: 10,
                    offset: Offset(5, 5),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
