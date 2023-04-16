part of 'profile_data_bloc.dart';

enum ProfileDataStatus { initial, success, failure }

enum ImageStatus { initial, changed, inProgrerss, success, failure }

class ProfileDataState extends Equatable {
  const ProfileDataState({
    this.imageStatus = ImageStatus.initial,
    this.dataStatus = ProfileDataStatus.initial,
    this.profileData = ProfileData.empty,
    this.inputData = const InputData.pure(),
    this.formzStatus = FormzStatus.pure,
    this.pickedImageFile = PickedImage.empty,
    this.inputEmail = const Email.pure(),
    this.groups = const <Group>[],
  });

  final ImageStatus imageStatus;
  final ProfileDataStatus dataStatus;
  final ProfileData profileData;
  final InputData inputData;
  final FormzStatus formzStatus;
  final PickedImage pickedImageFile;
  final Email inputEmail;
  final List<Group> groups;

  ProfileDataState copyWith({
    ImageStatus? imageStatus,
    ProfileDataStatus? dataStatus,
    ProfileData? profileData,
    InputData? inputData,
    FormzStatus? formzStatus,
    PickedImage? pickedImageFile,
    Email? inputEmail,
    List<Group>? groups,
  }) {
    return ProfileDataState(
      imageStatus: imageStatus ?? this.imageStatus,
      dataStatus: dataStatus ?? this.dataStatus,
      profileData: profileData ?? this.profileData,
      inputData: inputData ?? this.inputData,
      formzStatus: formzStatus ?? this.formzStatus,
      pickedImageFile: pickedImageFile ?? this.pickedImageFile,
      inputEmail: inputEmail ?? this.inputEmail,
      groups: groups ?? this.groups,
    );
  }

  @override
  List<Object> get props => [
        imageStatus,
        dataStatus,
        profileData,
        inputData,
        formzStatus,
        pickedImageFile,
        inputEmail,
        groups,
      ];
}
