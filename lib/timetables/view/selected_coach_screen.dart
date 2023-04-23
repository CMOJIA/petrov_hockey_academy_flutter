import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:petrov_hockey_academy_flutter/subscriptions/subscriptions.dart';
import 'package:petrov_hockey_academy_flutter/timetables/timetables.dart';
import 'package:petrov_hockey_academy_flutter/universal/universal.dart';

/// Страница распсиания выбранного тренера
class SelectedTraineerScreen extends StatefulWidget {
  const SelectedTraineerScreen({super.key, required this.coachId});

  final String coachId;

  @override
  State<SelectedTraineerScreen> createState() => _SelectedCoachScreenState();
}

class _SelectedCoachScreenState extends State<SelectedTraineerScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    ///  Установка состояния для DateTimePicker
    void _setDatePicker(DateTime date) {
      return setState(() {
        _selectedDate = date;
      });
    }

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        title: const Text('Запись на занятие'),
      ),
      // Использую билдер SubscriptionsBloc т.к. ко времени перехода
      // к индивидуальным тренировкам - список тренировок уже загружен.
      //
      // Чтобы проверять возможность записи - нужно грузить список абонементов.
      body: BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
        buildWhen: (previous, current) =>
            previous.subscriptionStatus != current.subscriptionStatus,
        builder: (context, state) {
          final _coach = context
              .select((TimetableBloc bloc) => bloc.state.coaches)
              .firstWhere((element) => element.coachId == widget.coachId);

          final _individuals =
              context.select((TimetableBloc bloc) => bloc.state.individuals);

          switch (state.subscriptionStatus) {
            case SubscriptionStatus.failure:
              return Center(
                child: Text(
                  'Ошибка загрузки.\nПроверьте интернет-подключение или повторите попытку позже.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              );
            case SubscriptionStatus.success:
              // Хоть у выбранного тренера не может НЕ быть расписания,
              // оставлю доп проверку на всякий
              if (_individuals.isEmpty) {
                return EmptyContent(
                  value: 'Нет расписания для выбранного тренера',
                  size: MediaQuery.of(context).size,
                );
              }
              return _SuccessContent(
                coach: _coach,
                coachId: widget.coachId,
                individuals: _individuals,
                selectedDate: _selectedDate,
                setDatePicker: _setDatePicker,
              );

            case SubscriptionStatus.initial:
              return _InitialContent(
                coach: _coach,
                setDatePicker: _setDatePicker,
              );
          }
        },
      ),
    );
  }
}

/// Содержимое при загрузке расписания тренера
class _InitialContent extends StatelessWidget {
  const _InitialContent({required this.coach, required this.setDatePicker});
  final Coach coach;
  final void Function(DateTime) setDatePicker;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CoachNameCard(coach: coach),
        _DatePicker(callback: setDatePicker),
        Divider(
          indent: 30,
          endIndent: 30,
          thickness: 1,
          color: Theme.of(context).primaryColorDark.withOpacity(0.5),
        ),
        Expanded(
          child: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ),
      ],
    );
  }
}

/// Содержимое когда расписание загрузилось
class _SuccessContent extends StatelessWidget {
  const _SuccessContent({
    required this.coach,
    required this.coachId,
    required this.individuals,
    required this.selectedDate,
    required this.setDatePicker,
  });
  final Coach coach;
  final void Function(DateTime) setDatePicker;
  final String coachId;
  final List<Individual> individuals;
  final DateTime selectedDate;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CoachNameCard(coach: coach),
        _DatePicker(callback: setDatePicker),
        Divider(
          indent: 30,
          endIndent: 30,
          thickness: 1,
          color: Theme.of(context).primaryColorDark.withOpacity(0.5),
        ),
        _Individuals(
          coachId: coachId,
          individuals: individuals,
          selectedDate: selectedDate,
        )
      ],
    );
  }
}

/// Список [ListView] индивидальных тренировок.
///
/// Показываются для конкретно выбраннного тренера
class _Individuals extends StatelessWidget {
  const _Individuals(
      {required this.individuals,
      required this.selectedDate,
      required this.coachId});
  final List<Individual> individuals;
  final DateTime selectedDate;
  final String coachId;
  @override
  Widget build(BuildContext context) {
    final _displaySize = MediaQuery.of(context).size;
    var _counter = 0;
    return Expanded(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          if (DateFormat.yMd().format(individuals[index].startDt) ==
                  DateFormat.yMd().format(selectedDate) &&
              individuals[index].coach.coachId == coachId) {
            _counter++;
            return IndividualsListItem(
              individual: individuals[index],
            );
          } else if (index == individuals.length - 1 && _counter == 0) {
            // Проверка есть ли расписание на выбранную дату
            return Padding(
              padding: EdgeInsets.only(
                top: _displaySize.height * 0.1,
                left: _displaySize.width * 0.05,
                right: _displaySize.width * 0.05,
              ),
              child: Text(
                'Расписание на выбранную дату не сформировано.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            );
          } else {
            return const SizedBox();
          }
        },
        itemCount: individuals.length,
      ),
    );
  }
}

/// Карточка с ФИО тренера
class _CoachNameCard extends StatelessWidget {
  const _CoachNameCard({required this.coach});
  final Coach coach;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '''Расписание   '''
                '''${coach.lastName} '''
                '''${coach.firstName.substring(0, 1).toUpperCase()}.'''
                '''${coach.middleName.substring(0, 1).toUpperCase()}.''',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Виджет выбора даты
class _DatePicker extends StatelessWidget {
  const _DatePicker({required this.callback});
  final void Function(DateTime) callback;
  @override
  Widget build(BuildContext context) {
    return DatePicker(
      DateTime.now(),
      height: 90,
      initialSelectedDate: DateTime.now(),
      selectionColor: Theme.of(context).primaryColor,
      selectedTextColor: Theme.of(context).scaffoldBackgroundColor,
      daysCount: 7,
      onDateChange: (date) {
        callback(date);
      },
    );
  }
}
