import 'package:equatable/equatable.dart';

class IndividualReport extends Equatable {
  const IndividualReport({
    required this.presence,
    required this.status,
    required this.title,
    required this.firstName,
    required this.middleName,
    required this.lastName,
  });

  final String presence;

  final String status;

  final String title;

  final String firstName;

  final String middleName;

  final String lastName;

  @override
  List<Object> get props =>
      [presence, status, title, firstName, middleName, lastName];
}
