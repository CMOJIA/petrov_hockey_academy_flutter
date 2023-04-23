import 'package:equatable/equatable.dart';

class Coach extends Equatable {
  const Coach({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.coachId,
    required this.photo,
    required this.path,
    required this.position,
  });

  final String firstName;

  final String middleName;

  final String lastName;

  final String coachId;

  final String? photo;

  final String path;

  final String position;

  @override
  List<Object> get props => [
        firstName,
        middleName,
        lastName,
        coachId,
        photo ?? '',
        path,
        position,
      ];
}
