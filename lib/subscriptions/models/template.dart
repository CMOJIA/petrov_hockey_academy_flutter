import 'package:equatable/equatable.dart';

class SubscriptionTemplate extends Equatable {
  const SubscriptionTemplate({
    required this.subscriptionId,
    required this.templateID,
    required this.student,
    required this.title,
    required this.description,
    required this.price,
    required this.type,
    required this.canBuyNextMonth,
    required this.startDt,
    required this.endDt,
  });

  final String? subscriptionId;

  final String templateID;

  final List<String> student;

  final String title;

  final String description;

  final String price;

  final String type;

  final int canBuyNextMonth;

  final DateTime? startDt;

  final DateTime? endDt;

  @override
  List<Object> get props => [
        subscriptionId ?? '',
        templateID,
        student,
        title,
        description,
        price,
        type,
        canBuyNextMonth,
        startDt ?? '',
        endDt ?? '',
      ];
}
