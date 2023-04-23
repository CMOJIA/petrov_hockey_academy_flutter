import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petrov_hockey_academy_flutter/subscriptions/subscriptions.dart';
import 'package:petrov_hockey_academy_flutter/timetables/timetables.dart';
import 'package:petrov_hockey_academy_flutter/transitions/transitions.dart';

/// Виджет тренера, к которому возможно записаться на тренировку.
///
/// По нажатию вполняется переход к расписанию этого тренера.
class CoachListItem extends StatelessWidget {
  const CoachListItem({super.key, required Coach coach}) : _coach = coach;

  final Coach _coach;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: InkWell(
          splashColor: Theme.of(context).primaryColor,
          highlightColor: Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CoachAvatar(coach: _coach),
              ],
            ),
            title: _Title(coach: _coach),
            subtitle: _CoachPosition(
              coach: _coach,
            ),
            trailing: _Trailing(),
          ),
          key: ValueKey(_coach.coachId),
          onTap: () => Navigator.push(
            context,
            FadeRoute(
              builder: (
                ctx,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
              ) {
                // Чтобы проверять возможность записи - нужно грузить список абонементов.
                return BlocProvider.value(
                  value: BlocProvider.of<SubscriptionsBloc>(context)
                    ..add(SubscriptionsFetched()),
                  child: SelectedTraineerScreen(coachId: _coach.coachId),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Иконка в конце [ListTile]
class _Trailing extends StatelessWidget {
  const _Trailing();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: Icon(
        size: 25,
        Icons.arrow_forward_ios_rounded,
      ),
    );
  }
}

/// Должность тренера
class _CoachPosition extends StatelessWidget {
  const _CoachPosition({required this.coach});
  final Coach coach;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        coach.position,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// ФИО тренера
class _Title extends StatelessWidget {
  const _Title({required this.coach});
  final Coach coach;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        '''${coach.lastName} '''
        '''${coach.firstName.substring(0, 1).toUpperCase()}.'''
        '''${coach.middleName.substring(0, 1).toUpperCase()}.''',
        style: const TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Аватар тренера
class _CoachAvatar extends StatelessWidget {
  const _CoachAvatar({required this.coach});
  final Coach coach;

  @override
  Widget build(BuildContext context) {
    // Прверка на наличие фото тренера
    if (coach.photo == null)
      return const CircleAvatar(
        radius: 27,
        foregroundImage: AssetImage(
          'assets/logo.png',
        ),
      );
    else
      return CircleAvatar(
        radius: 27,
        foregroundImage: NetworkImage(
          '${coach.path}/${coach.photo}',
        ),
        // Чтобы не было вокруг аватара рамки
        backgroundColor: Colors.transparent,
      );
  }
}
