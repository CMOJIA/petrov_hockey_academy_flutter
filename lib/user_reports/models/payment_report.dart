import 'package:equatable/equatable.dart';

class PaymentReport extends Equatable {
  const PaymentReport({
    required this.description,
    required this.name,
    required this.status,
    required this.type,
    required this.createdAt,
    required this.amount,
  });

  final String description;

  final String name;

  final String status;

  final String type;

  final DateTime createdAt;

  final int amount;

  @override
  List<Object> get props => [
        description,
        name,
        status,
        type,
        createdAt,
        amount,
      ];
}
