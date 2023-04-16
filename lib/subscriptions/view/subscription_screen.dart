import 'dart:ui';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petrov_hockey_academy_flutter/universal/universal.dart';
import 'package:petrov_hockey_academy_flutter/subscriptions/subscriptions.dart';
import 'package:shimmer/shimmer.dart';

enum TemplateType {
  all,
  season,
  period,
}

/// Экран со списком абонементов, содержит фильтр по ученикам и типу абонементов
class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  var _type = TemplateType.all;
  Student? _selectedStudent;

  @override
  Widget build(BuildContext context) {
    final _displaySize = MediaQuery.of(context).size;

    // Установка состояния для фильтра студентов
    void _setStudentFilter(Student student) {
      return setState(
        () {
          _selectedStudent = student;
        },
      );
    }

    // Установка состояния для фильтра типа абонементов
    void _setTemplateType(TemplateType type) {
      return setState(() {
        _type = type;
      });
    }

    return BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
      buildWhen: (previous, current) =>
          previous.subscriptionStatus != current.subscriptionStatus,
      builder: (context, state) {
        switch (state.subscriptionStatus) {
          case SubscriptionStatus.failure:
            return _FailureContent(
              size: _displaySize,
            );
          case SubscriptionStatus.success:
            if (state.subscriptionsTemplates.isEmpty) {
              return EmptyContent(
                  value: 'Абонементы отстутвуют.', size: _displaySize);
            }
            return _SuccessContent(
              selectedStudent: _selectedStudent,
              setStudentFilter: _setStudentFilter,
              setTemplateType: _setTemplateType,
              state: state,
              type: _type,
            );
          case SubscriptionStatus.initial:
            return _SubscriptionsShimmer();
        }
      },
    );
  }
}

/// Контент когда загрузка данных завершилась успешно
class _SuccessContent extends StatelessWidget {
  const _SuccessContent({
    required this.selectedStudent,
    required this.state,
    required this.type,
    required this.setStudentFilter,
    required this.setTemplateType,
  });
  final Student? selectedStudent;
  final TemplateType type;
  final SubscriptionsState state;
  final Function(Student) setStudentFilter;
  final Function(TemplateType) setTemplateType;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 8,
        ),
        _StudentFilter(
            callback: setStudentFilter,
            selectedStudent: selectedStudent,
            students: state.students),
        _TemplateTypeFilter(type: type, callback: setTemplateType),
        Divider(
          indent: 30,
          endIndent: 30,
          thickness: 1,
          color: Theme.of(context).primaryColorDark.withOpacity(0.5),
        ),
        Expanded(
          child: ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Align(
              alignment: Alignment.topCenter,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return AviableForBuying(
                      index: index,
                      state: state,
                      selectedStudent: selectedStudent,
                      type: type);
                },
                itemCount: state.subscriptionsTemplates.length,
              ),
            ),
          ),
        ),
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
              context.read<SubscriptionsBloc>().add(SubscriptionsFetched());
            },
            authenticationRepository: context.read<AuthenticationRepository>(),
          ),
        ],
      ),
    );
  }
}

/// Фильтр студентов
class _StudentFilter extends StatelessWidget {
  const _StudentFilter(
      {required this.students,
      required this.selectedStudent,
      required this.callback});
  final List<Student> students;
  final Student? selectedStudent;
  final Function(Student) callback;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        onTap: () {
          showGeneralDialog<String>(
            context: context,
            pageBuilder: (context, anim1, anim2) {
              return Container();
            },
            transitionDuration: const Duration(milliseconds: 200),
            transitionBuilder: (context, anim1, anim2, child) {
              return Transform.scale(
                scale: anim1.value,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: SimpleDialog(
                    title: const Text(
                      'Выберите ученика:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SizedBox(
                          height: students.length * 52,
                          width: 300,
                          child: ListView.builder(
                            // По умолчанию был какой-то отсутп сверху
                            padding: EdgeInsets.only(bottom: 16),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: students.length,
                            itemBuilder: (BuildContext context, int index) {
                              return SimpleDialogOption(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 16,
                                ),
                                key: ValueKey(students[index].id),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  return callback(students[index]);
                                },
                                child: Text(
                                  '''${students[index].firstName} '''
                                  '''${students[index].middleName.substring(0, 1).toUpperCase()}.'''
                                  '''${students[index].lastName.substring(0, 1).toUpperCase()}.''',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(
                selectedStudent == null
                    // Если ученик еще не выбран
                    // Выбирается первый ученик по умолчанию
                    ? '''Ученик: '''
                        '''${students.first.firstName} '''
                        '''${students.first.middleName.substring(0, 1).toUpperCase()}.'''
                        ''' ${students.first.lastName.substring(0, 1).toUpperCase()}.'''
                    : '''Ученик: '''
                        '''${selectedStudent?.firstName} '''
                        '''${selectedStudent?.middleName.substring(0, 1).toUpperCase()}.'''
                        ''' ${selectedStudent?.lastName.substring(0, 1).toUpperCase()}.''',
                style: Theme.of(context).textTheme.bodyMedium,
                softWrap: false,
                overflow: TextOverflow.fade,
              )),
              Icon(
                Icons.arrow_forward_ios_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Фильтр типа абонемента
class _TemplateTypeFilter extends StatelessWidget {
  const _TemplateTypeFilter({required this.type, required this.callback});
  final TemplateType type;
  final Function(TemplateType) callback;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        onTap: () {
          showGeneralDialog<String>(
            context: context,
            pageBuilder: (context, anim1, anim2) {
              return Container();
            },
            transitionBuilder: (context, anim1, anim2, child) {
              return Transform.scale(
                scale: anim1.value,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: SimpleDialog(
                    title: const Text(
                      'Выберите абонементы:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    children: [
                      // All
                      _TemplateTypeDialogOption(
                          type: TemplateType.all,
                          value: 'Все фильтры',
                          callback: callback),
                      // Season
                      _TemplateTypeDialogOption(
                        type: TemplateType.season,
                        value: 'Сезонные абонементы',
                        callback: callback,
                      ),
                      // Period
                      _TemplateTypeDialogOption(
                        type: TemplateType.period,
                        value: 'Ежемесячные абонементы',
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  // All
                  type == TemplateType.all
                      ? 'Все фильтры'
                      // Season
                      : type == TemplateType.season
                          ? 'Сезонные абонементы'
                          // Period
                          : 'Ежемесячные абонементы',
                  style: Theme.of(context).textTheme.bodyMedium),
              Icon(
                Icons.arrow_forward_ios,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Элемент диалогового окна выбора типа абонементов
class _TemplateTypeDialogOption extends StatelessWidget {
  const _TemplateTypeDialogOption({
    required this.value,
    required this.type,
    required this.callback,
  });
  final String value;
  final TemplateType type;
  final Function(TemplateType) callback;
  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 16,
      ),
      key: ValueKey(type),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        callback(type);
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

/// Шиммер при загрузке данных
///
/// Эксперимеинтальная верстка
class _SubscriptionsShimmer extends StatelessWidget {
  _SubscriptionsShimmer();

  final itemHeight = 64.0;
  final listItemHeight = 204.0;
  final color = Colors.grey[400];
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              height: itemHeight * 2,
              child: ListView.builder(
                itemBuilder: (_, __) => SizedBox(
                  height: itemHeight,
                  width: constraints.maxWidth,
                  child: Shimmer.fromColors(
                    baseColor: color!,
                    highlightColor: Colors.grey[300]!,
                    child: Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                ),
                itemCount: 2,
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
                  height: listItemHeight,
                  child: Shimmer.fromColors(
                    baseColor: color!,
                    highlightColor: Colors.grey[300]!,
                    child: Card(
                      color: color,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                ),
                itemCount: (constraints.maxHeight / listItemHeight).ceil(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
