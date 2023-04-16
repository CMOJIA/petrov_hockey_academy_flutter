import 'package:image_picker/image_picker.dart';

class PickedImage {
  const PickedImage({
    required this.photo,
  });

  static const empty = PickedImage(photo: null);

  final XFile? photo;
}
