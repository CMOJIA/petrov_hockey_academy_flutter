part of 'media_bloc.dart';

abstract class MediaEvent extends Equatable {
  const MediaEvent();

  @override
  List<Object> get props => [];
}

class MediaFetched extends MediaEvent {}

class GroupsFetched extends MediaEvent {}

class MediaAlbumLoadedMore extends MediaEvent {}

class MediaVideoLoadedMore extends MediaEvent {}

class MediaImagesPicked extends MediaEvent {
  const MediaImagesPicked(this.images);
  final List<AssetEntity>? images;
}

class MediaAlbumSubmitted extends MediaEvent {
  const MediaAlbumSubmitted(this.author);
  final String author;
}

class MediaVideoSubmitted extends MediaEvent {
  const MediaVideoSubmitted(this.author);
  final String author;
}

class MediaSelectedGroupChanged extends MediaEvent {
  const MediaSelectedGroupChanged(this.groupId);
  final int groupId;
}

class AddMediaSettedInitialState extends MediaEvent {
  const AddMediaSettedInitialState(this.groupId);
  final int groupId;
}

class MediaVideoTitleInputChanged extends MediaEvent {
  const MediaVideoTitleInputChanged(this.inputTitle);
  final String inputTitle;
}

class MediaAlbumTitleInputChanged extends MediaEvent {
  const MediaAlbumTitleInputChanged(this.inputTitle);
  final String inputTitle;
}

class MediaUrlInputChanged extends MediaEvent {
  const MediaUrlInputChanged(this.inputUrl);
  final String inputUrl;
}
