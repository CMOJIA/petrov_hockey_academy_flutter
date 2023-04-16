import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petrov_hockey_academy_flutter/media/bloc/media_bloc.dart';
import 'package:petrov_hockey_academy_flutter/profile_data/bloc/profile_data_bloc.dart';

/// Универсальный [DropdownButton] для выбора группы альбома/видео
class GroupSelectionDropdownButton extends StatelessWidget {
  const GroupSelectionDropdownButton();

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<ProfileDataBloc>().state.groups;

    return BlocBuilder<MediaBloc, MediaState>(
      buildWhen: (previous, current) =>
          previous.selectedGroupId != current.selectedGroupId,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Группа:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).primaryColorDark.withOpacity(0.6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      items: groups.map((e) {
                        return DropdownMenuItem<String>(
                          value: e.groupId,
                          child: Text(
                            '● ${e.title}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                        );
                      }).toList(),
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(20),
                      dropdownColor: Colors.black.withOpacity(0.8),
                      iconEnabledColor: Colors.white70,
                      value: groups
                          .firstWhere(
                            (element) =>
                                element.groupId ==
                                state.selectedGroupId.toString(),
                          )
                          .groupId,
                      alignment: AlignmentDirectional.centerEnd,
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                      ),
                      onChanged: (String? value) {
                        final index = groups.indexWhere(
                          (e) => e.groupId == value,
                        );
                        context.read<MediaBloc>().add(
                              MediaSelectedGroupChanged(
                                int.parse(
                                  groups[index].groupId,
                                ),
                              ),
                            );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
