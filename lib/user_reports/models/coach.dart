import 'package:equatable/equatable.dart';

class Coach extends Equatable {
  const Coach({
    required this.firstName,
    required this.middleName,
    required this.lastName,
  });

  final String firstName;

  final String middleName;

  final String lastName;

  @override
  List<Object> get props => [firstName, middleName, lastName];
}
