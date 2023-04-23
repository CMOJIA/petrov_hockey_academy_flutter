import 'dart:ui';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:petrov_hockey_academy_flutter/timetables/timetables.dart';
import 'package:petrov_hockey_academy_flutter/universal/universal.dart';
import 'package:shimmer/shimmer.dart';

enum FilterOptions {
  free,
  paid,
  individuals,
}

/// Экран с расписаниями тренировок, тип расписания выбирается с помощью фильтра
class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});
  // При переключении вкладок фильтр остается, но при смене пользователя - возвращаю значение по умолчанию
  static FilterOptions filter = FilterOptions.free;

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final _displaySize = MediaQuery.of(context).size;

    ///  Установка состояния для DatePicker
    void _setDatePicker(DateTime date) {
      return setState(() {
        _selectedDate = date;
      });
    }

    ///  Установка состояния для фильтра типа расписания
    void _setTimetableFilter(FilterOptions filter) {
      setState(() {
        TimetableScreen.filter = filter;
      });
    }

    return BlocBuilder<TimetableBloc, TimetableState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        switch (state.status) {
          case TimeTableStatus.failure:
            return _FailureContent(
              size: _displaySize,
            );
          case TimeTableStatus.success:
            if (state.trainingsFree.isEmpty &&
                state.trainingsPaid.isEmpty &&
                state.individuals.isEmpty) {
              return EmptyContent(
                  value: 'Расписание не сформировано.', size: _displaySize);
            }
            return _SuccessContent(
              selectedDate: _selectedDate,
              setDatePicker: _setDatePicker,
              setTimetableFilter: _setTimetableFilter,
              state: state,
            );

          case TimeTableStatus.initial:
            return _TimetableShimmer();
        }
      },
    );
  }
}

/// Контент когда загрузка данных завершилась успешно
class _SuccessContent extends StatelessWidget {
  const _SuccessContent({
    required this.selectedDate,
    required this.setDatePicker,
    required this.setTimetableFilter,
    required this.state,
  });
  final void Function(DateTime) setDatePicker;
  final void Function(FilterOptions) setTimetableFilter;
  final TimetableState state;
  final DateTime selectedDate;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (TimetableScreen.filter != FilterOptions.individuals)
          _DatePicker(callback: setDatePicker),
        _TimetableFilter(callback: setTimetableFilter),
        Divider(
          indent: 30,
          endIndent: 30,
          thickness: 1,
          color: Theme.of(context).primaryColorDark.withOpacity(0.5),
        ),
        if (TimetableScreen.filter == FilterOptions.free)
          // Расписание бюджетных тренировок
          _FreeTimetable(
            budget: state.trainingsFree,
            selectedDate: selectedDate,
          )
        else if (TimetableScreen.filter == FilterOptions.paid)
          // Расписание платных тренировок
          _PaidTimetable(
            paid: state.trainingsPaid,
            selectedDate: selectedDate,
          )
        else
          // Расписание индивидуальных тренировок
          _IndividualsTimetable(
            coaches: state.coaches,
          )
      ],
    );
  }
}

/// Контент когда загрузка данных завершилась ошибкой
class _FailureContent extends StatelessWidget {
  const _FailureContent({required this.size});
  final Size size;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: size.width * 0.1,
        right: size.width * 0.1,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Ошибка загрузки.\nПроверьте интернет-подключение или повторите попытку позже.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          RefreshButton(
            onTap: () {
              context.read<TimetableBloc>().add(TimetableFetched());
            },
            authenticationRepository: context.read<AuthenticationRepository>(),
          ),
        ],
      ),
    );
  }
}

/// [ListView] платных тренировок
class _PaidTimetable extends StatelessWidget {
  _PaidTimetable({required this.paid, required this.selectedDate});
  final List<TrainingPaid> paid;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final _displaySize = MediaQuery.of(context).size;
    var _counter = 0;
    return paid.isEmpty
        ? Padding(
            padding: EdgeInsets.only(
              top: _displaySize.height * 0.1,
              left: _displaySize.width * 0.1,
              right: _displaySize.width * 0.1,
            ),
            child: Text(
              'Расписание платных групп не составлено.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          )
        : Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                if (DateFormat.yMd().format(paid[index].startDt) ==
                    DateFormat.yMd().format(selectedDate)) {
                  _counter++;
                  return PaidListItem(trainingPaid: paid[index]);
                } else if (index == paid.length - 1 && _counter == 0) {
                  // Проверка есть ли расписание на выбранную дату
                  return Padding(
                    padding: EdgeInsets.only(
                      top: _displaySize.height * 0.1,
                      left: _displaySize.width * 0.05,
                      right: _displaySize.width * 0.05,
                    ),
                    child: Center(
                      child: Text(
                        'Расписание на выбранную дату не сформировано.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              },
              itemCount: paid.length,
            ),
          );
  }
}

/// [ListView] бюджетных тренировок
class _FreeTimetable extends StatelessWidget {
  const _FreeTimetable({required this.budget, required this.selectedDate});
  final List<TrainingFree> budget;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final _displaySize = MediaQuery.of(context).size;
    var _counter = 0;
    return budget.isEmpty
        ? Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: _displaySize.height * 0.1,
                left: _displaySize.width * 0.1,
                right: _displaySize.width * 0.1,
              ),
              child: Text(
                'Расписание бюджетных групп не составлено.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          )
        : Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                if (DateFormat.yMd().format(budget[index].startDt) ==
                    DateFormat.yMd().format(selectedDate)) {
                  _counter++;
                  return FreeListItem(trainingsFree: budget[index]);
                } else if (index == budget.length - 1 && _counter == 0) {
                  // Проверка есть ли расписание на выбранную дату
                  return Padding(
                    //заменить пиксели на mediaquery
                    padding: EdgeInsets.only(
                      top: _displaySize.height * 0.1,
                      left: _displaySize.width * 0.05,
                      right: _displaySize.width * 0.05,
                    ),
                    child: Center(
                      child: Text(
                        'Расписание на выбранную дату не сформировано.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              },
              itemCount: budget.length,
            ),
          );
  }
}

/// [ListView] индвидуальных тренировок
class _IndividualsTimetable extends StatelessWidget {
  const _IndividualsTimetable({required this.coaches});
  final List<Coach> coaches;
  @override
  Widget build(BuildContext context) {
    final _displaySize = MediaQuery.of(context).size;
    return coaches.isEmpty
        ? Padding(
            padding: EdgeInsets.only(
              top: _displaySize.height * 0.1,
              left: _displaySize.width * 0.1,
              right: _displaySize.width * 0.1,
            ),
            child: Text(
              'Расписание индивидуальных тренировок не составлено.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          )
        : Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return CoachListItem(coach: coaches[index]);
              },
              itemCount: coaches.length,
            ),
          );
  }
}

/// Виджет выбора даты [DatePicker]
class _DatePicker extends StatelessWidget {
  const _DatePicker({required this.callback});
  final void Function(DateTime) callback;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DatePicker(
        DateTime.now(),
        locale: 'ru',
        height: 90,
        initialSelectedDate: DateTime.now(),
        selectionColor: Theme.of(context).primaryColor,
        selectedTextColor: Theme.of(context).scaffoldBackgroundColor,
        daysCount: 14,
        onDateChange: (date) {
          callback(date);
        },
      ),
    );
  }
}

/// Элемент диалогового окна фильтра типа расписания
class _TimetableTypeDialogOption extends StatelessWidget {
  const _TimetableTypeDialogOption({
    required this.filter,
    required this.value,
    required this.callback,
  });
  final FilterOptions filter;
  final String value;
  final Function(FilterOptions) callback;
  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 16,
      ),
      key: ValueKey(filter),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        callback(filter);
      },
      child: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    );
  }
}

/// Фильтр выбра типа распсиания
class _TimetableFilter extends StatelessWidget {
  const _TimetableFilter({
    required this.callback,
  });
  final void Function(FilterOptions) callback;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        elevation: 5,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          onTap: () {
            showGeneralDialog<String>(
              context: context,
              pageBuilder: (context, anim1, anim2) {
                return const SizedBox();
              },
              transitionBuilder: (context, anim1, anim2, child) {
                return Transform.scale(
                  scale: anim1.value,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: SimpleDialog(
                      title: const Text(
                        'Выберите тип расписания:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      children: [
                        _TimetableTypeDialogOption(
                          filter: FilterOptions.free,
                          value: 'Бюджетные группы',
                          callback: callback,
                        ),
                        _TimetableTypeDialogOption(
                          filter: FilterOptions.paid,
                          value: 'Платные группы',
                          callback: callback,
                        ),
                        _TimetableTypeDialogOption(
                          filter: FilterOptions.individuals,
                          value: 'Индивидуальные занятия',
                          callback: callback,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TimetableScreen.filter == FilterOptions.free
                      ? 'Бюджетные группы'
                      : TimetableScreen.filter == FilterOptions.paid
                          ? 'Платные группы'
                          : 'Индивидуальные занятия',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Шиммер при загрузке даннных.
///
/// Экспериментальная верстка.
class _TimetableShimmer extends StatelessWidget {
  const _TimetableShimmer();

  @override
  Widget build(BuildContext context) {
    final color = Colors.grey[400];
    return AbsorbPointer(
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            // DatePicker
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Shimmer.fromColors(
                baseColor: color!,
                highlightColor: Colors.grey[300]!,
                child: Row(
                  children: [
                    Container(
                      height: 84,
                      width: 60,
                      margin: EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        color: Colors.grey[400],
                      ),
                    ),
                    Container(
                      height: 84,
                      width: constraints.maxWidth - 72,
                      margin: EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                height: 75,
                width: constraints.maxWidth,
                child: Shimmer.fromColors(
                  baseColor: color,
                  highlightColor: Colors.grey[300]!,
                  child: Card(),
                ),
              ),
            ),
            Divider(
              indent: 30,
              endIndent: 30,
              thickness: 1,
              color: color,
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (_, __) => SizedBox(
                  height: 105,
                  width: constraints.maxWidth,
                  child: Shimmer.fromColors(
                    baseColor: color,
                    highlightColor: Colors.grey[300]!,
                    child: Card(),
                  ),
                ),
                itemCount: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
