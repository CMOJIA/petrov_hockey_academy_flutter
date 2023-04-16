import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:petrov_hockey_academy_flutter/universal/universal.dart';
import 'package:petrov_hockey_academy_flutter/subscriptions/subscriptions.dart';
import 'package:petrov_hockey_academy_flutter/timetables/timetables.dart';

/// Страница записи на индивидуальную тренировку
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({
    super.key,
    required this.subscriptionId,
    required this.students,
    required this.individual,
  });

  final String subscriptionId;
  final List<Student> students;
  final Individual individual;
  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMMM', 'ru');
    final time = DateFormat.Hm();

    // Даилоговое окно в ответ на результат записи на тренировку
    void _showAttendanceDialog({
      required String title,
      required String content,
      required Function(void) thenFunc,
      required AttendanceStatus status,
    }) {
      warningDialog(
        context: context,
        title: title,
        content: content,
      ).then(thenFunc);
    }

    return BlocListener<SubscriptionsBloc, SubscriptionsState>(
      listener: (context, state) {
        if (state.attendanceStatus == AttendanceStatus.failure) {
          _showAttendanceDialog(
            content:
                'Не удалось записаться. Проверьте подключение к интернету или попробуйте позже.',
            status: state.attendanceStatus,
            title: 'Ошибка',
            thenFunc: (_) {
              Navigator.of(context).pop();
            },
          );
        }
        if (state.attendanceStatus == AttendanceStatus.success) {
          // Если запись произошла успешно -  изменяю данные локально
          context.read<TimetableBloc>().add(TimetableIndividualAttendance(
              individual, state.selectedStudentId));
          _showAttendanceDialog(
            content:
                'Запись на тренировку ${date.format(individual.startDt)} успешно произведена.',
            status: state.attendanceStatus,
            title: 'Успешно!',
            thenFunc: (_) {
              Navigator.of(context).pop();
            },
          );
        }
        // Уже записан (проверяется на стороне приложения, но на всякий сучай добавил обработку такого ответа)
        if (state.attendanceStatus == AttendanceStatus.alreadyAttend) {
          _showAttendanceDialog(
            title: 'Ошибка',
            content: 'Вы уже записаны на эту тренировку.',
            thenFunc: (_) {
              Navigator.of(context).pop();
            },
            status: AttendanceStatus.alreadyAttend,
          );
        }
      },
      child: BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
        buildWhen: (previous, current) =>
            previous.attendanceStatus != current.attendanceStatus,
        builder: (context, state) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
            child: Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                        ),
                        label: Text(
                          'Назад',
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      // Заголовок страницы
                      const Text(
                        'Записаться на тренировку',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      _AttendanceData(
                        label: 'Дата и время:',
                        text: '''${date.format(individual.startDt)} '''
                            '''${time.format(individual.startDt)}-${time.format(individual.endDt)}''',
                      ),

                      _AttendanceData(
                        label: 'Площадка:',
                        text: individual.area,
                      ),

                      _AttendanceData(
                        label: 'Тренер:',
                        text: '''${individual.coach.lastName} '''
                            '''${individual.coach.firstName.substring(0, 1).toUpperCase()}.'''
                            '''${individual.coach.middleName.substring(0, 1).toUpperCase()}.''',
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      _StudentData(
                          students: students, subscriptionId: subscriptionId),

                      const Spacer(),

                      _AttendanceButton(
                        color: const Color.fromARGB(255, 70, 165, 37),
                        value: 'Записаться',
                        onPressed: () {
                          context.read<SubscriptionsBloc>().add(
                                SubscriptionsAttendance(
                                  studentId: int.parse(
                                    state.selectedStudentId,
                                  ),
                                  subscriptionId: int.parse(subscriptionId),
                                  trainingId: int.parse(individual.trainingId),
                                ),
                              );
                        },
                        isAttendanceButton: true,
                        attendanceStatus: state.attendanceStatus,
                      ),
                      // Кнопка отмены записи
                      _AttendanceButton(
                        color: const Color.fromARGB(255, 195, 66, 68),
                        value: 'Отменить',
                        onPressed: () => Navigator.of(context).pop(),
                        isAttendanceButton: false,
                        attendanceStatus: state.attendanceStatus,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Данные о выбранной тренировки
class _AttendanceData extends StatelessWidget {
  const _AttendanceData({required this.label, required this.text});
  final String label;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
            ),
          ),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ФИО студента
class _StudentData extends StatelessWidget {
  const _StudentData({required this.students, required this.subscriptionId});
  final String subscriptionId;
  final List<Student> students;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
      buildWhen: (previous, current) =>
          previous.selectedStudentId != current.selectedStudentId,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Ученик:',
                style: TextStyle(
                  fontSize: 22,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).primaryColorDark,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    items:
                        // студенты  которые есть в списке студентов конкретного шаблона по subs_id
                        students
                            .where(
                      (element) => state.subscriptionsTemplates
                          .firstWhere(
                            (e) => e.subscriptionId == subscriptionId,
                          )
                          .student
                          .contains(element.id),
                    )
                            .map((e) {
                      return DropdownMenuItem<String>(
                        value: e.id,
                        child: Text(
                          '''${e.middleName} '''
                          '''${e.firstName.substring(0, 1).toUpperCase()}.'''
                          '''${e.firstName.substring(0, 1).toUpperCase()}.''',
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
                    dropdownColor: Colors.black.withOpacity(0.9),
                    iconEnabledColor: Colors.white70,
                    value: students
                        .firstWhere(
                          (element) => element.id == state.selectedStudentId,
                        )
                        .id,
                    alignment: AlignmentDirectional.centerEnd,
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                    // На изменение выбранного студента по его id находится
                    // сам экземпляр студента и отпралвяется соответствующий ивент в блок
                    onChanged: students.length > 1
                        ? (String? value) {
                            final index = students.indexWhere(
                              (e) => e.id == value,
                            );
                            context.read<SubscriptionsBloc>().add(
                                  SubscriptionsSelectedStudentChanged(
                                    state.students[index].id,
                                  ),
                                );
                          }
                        : null,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Кнопка отправки запроса на запись на тренировку или отмены записи,
/// в зависимости от передаваемых аргументов
class _AttendanceButton extends StatelessWidget {
  const _AttendanceButton({
    required this.color,
    required this.value,
    required this.onPressed,
    required this.isAttendanceButton,
    required this.attendanceStatus,
  });

  final Color color;
  final String value;
  final VoidCallback onPressed;
  final bool isAttendanceButton;
  final AttendanceStatus attendanceStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
        key: ValueKey(value),
        onPressed: onPressed,
        child: isAttendanceButton &&
                attendanceStatus == AttendanceStatus.inProgress
            ? Container(
                height: 51,
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, containerConstraints) {
                    return SizedBox(
                      height: containerConstraints.maxHeight,
                      width: containerConstraints.maxHeight,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  },
                ))
            : Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  value,
                ),
              ),
      ),
    );
  }
}
