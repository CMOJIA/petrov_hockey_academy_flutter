import 'package:equatable/equatable.dart';

class ProfileData extends Equatable {
  const ProfileData({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.photo,
    required this.phoneNumber,
    required this.isRedactor,
    required this.email,
  });

  static const empty = ProfileData(
    firstName: '',
    middleName: '',
    lastName: '',
    photo: '',
    phoneNumber: '',
    isRedactor: false,
    email: '',
  );

  final String firstName;

  final String middleName;

  final String lastName;

  final String? photo;

  final String phoneNumber;

  final bool isRedactor;

  final String email;

  @override
  List<Object> get props => [
        firstName,
        middleName,
        lastName,
        photo ?? '',
        phoneNumber,
        isRedactor,
        email
      ];
}
