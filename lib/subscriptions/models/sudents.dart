import 'package:equatable/equatable.dart';

class Student extends Equatable {
  const Student({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
  });

  final String id;

  final String firstName;

  final String middleName;

  final String lastName;

  @override
  List<Object> get props => [id, firstName, middleName, lastName];
}
