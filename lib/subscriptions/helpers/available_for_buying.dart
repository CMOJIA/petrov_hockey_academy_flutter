import 'package:flutter/material.dart';
import 'package:petrov_hockey_academy_flutter/subscriptions/subscriptions.dart';

/// Определяется возможно ли купить абонемент, если нет возвращается [SizedBox]
class AviableForBuying extends StatelessWidget {
  const AviableForBuying({
    required this.index,
    required this.selectedStudent,
    required this.state,
    required this.type,
  });
  final int index;

  final SubscriptionsState state;

  final Student? selectedStudent;

  final TemplateType type;

  @override
  Widget build(BuildContext context) {
    // Если абонемент доступен для ученика
    if (state.subscriptionsTemplates[index].student
        .toString()
        .contains(state.students.first.id)) {
      // Если выбраны сезонные абонемента и выбранный элемент тип season
      if (type == TemplateType.season &&
          state.subscriptionsTemplates[index].type == 'season') {
        // Если season и уже есть подписка
        if (state.subscriptionsTemplates[index].subscriptionId != null) {
          // Если месяц окончания подписки > текущего месяца - нельзя купить(не отображается)
          if (state.subscriptionsTemplates[index].endDt!.month >
              DateTime.now().month) {
            return const SizedBox();
          } // Иначе купить можно
          else {
            return SubscriptionListItem(
              subscription: state.subscriptionsTemplates[index],
              student: selectedStudent ?? state.students.first,
              index: index,
            );
          }
        } // Если подписки нет
        else {
          return SubscriptionListItem(
            subscription: state.subscriptionsTemplates[index],
            student: selectedStudent ?? state.students.first,
            index: index,
          );
        }
      } // Если выбраны переодические абонементы и выбранный элемент тип period
      else if (type == TemplateType.period &&
          state.subscriptionsTemplates[index].type == 'period') {
        return SubscriptionListItem(
          subscription: state.subscriptionsTemplates[index],
          student: selectedStudent ?? state.students.first,
          index: index,
        );
      }
      // Если выбраны все абонементы
      else if (type == TemplateType.all) {
        // Если есть подписка
        if (state.subscriptionsTemplates[index].endDt != null) {
          // Если месяц окончания подписки > текущего месяца - нельзя купить(не отображается)
          if (state.subscriptionsTemplates[index].endDt!.month >
              DateTime.now().month) {
            return const SizedBox();
          } // Иначе купить можно
          else {
            return SubscriptionListItem(
              subscription: state.subscriptionsTemplates[index],
              student: selectedStudent ?? state.students.first,
              index: index,
            );
          }
        } //  Если нет подписки
        else {
          return SubscriptionListItem(
            subscription: state.subscriptionsTemplates[index],
            student: selectedStudent ?? state.students.first,
            index: index,
          );
        }
      } else {
        return const SizedBox();
      }
    } else {
      return const SizedBox();
    }
  }
}
