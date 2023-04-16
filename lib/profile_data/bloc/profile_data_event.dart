part of 'profile_data_bloc.dart';

abstract class ProfileDataEvent extends Equatable {
  const ProfileDataEvent();

  @override
  List<Object> get props => [];
}

class ProfileDataFetched extends ProfileDataEvent {}

class ProfileDataInputDataChanged extends ProfileDataEvent {
  const ProfileDataInputDataChanged(this.inputData);
  final String inputData;
}

class ProfileDataPickedImageChanged extends ProfileDataEvent {
  const ProfileDataPickedImageChanged(this.pickedImageFile);
  final XFile? pickedImageFile;
}

class ProfileDataInputEmailChanged extends ProfileDataEvent {
  const ProfileDataInputEmailChanged(this.inputEmail);
  final String inputEmail;
}

class ProfileDataFirstNameSubmitted extends ProfileDataEvent {}

class ProfileDataMiddleNameSubmitted extends ProfileDataEvent {}

class ProfileDataLastNameSubmitted extends ProfileDataEvent {}

class ProfileDataPhoneNumberSubmitted extends ProfileDataEvent {}

class ProfileDataEmailSubmetted extends ProfileDataEvent {}

class ProfileDataPickedImageSubmitted extends ProfileDataEvent {}

class ProfileDataInputClosed extends ProfileDataEvent {}
