import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petrov_hockey_academy_flutter/universal/universal.dart';
import 'package:petrov_hockey_academy_flutter/profile_data/profile_data.dart';

final picker = ImagePicker();

/// Сделать фотографию
Future<void> _pickImageFromCamera(BuildContext context) async {
  final pickedImageFile = await picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 50,
    maxWidth: 150,
  );
  if (pickedImageFile != null) {
    context
        .read<ProfileDataBloc>()
        .add(ProfileDataPickedImageChanged(pickedImageFile));
  }
}

/// Выбрать фотографию из галереи
Future<void> _pickImageFromGallery(BuildContext context) async {
  final pickedImageFile = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 50,
    maxWidth: 150,
  );
  // Если пользователь выбрал фото - оно добавляются в стейт
  if (pickedImageFile != null) {
    context
        .read<ProfileDataBloc>()
        .add(ProfileDataPickedImageChanged(pickedImageFile));
  }
}

/// Форма в виде ModalBottomSheet редактирования аватара пользователя
void imagePicker(
  BuildContext context,
) {
  showModalBottomSheet<void>(
    isScrollControlled: true,
    context: context,
    builder: (_) {
      return BlocProvider.value(
        value: BlocProvider.of<ProfileDataBloc>(context),
        child: BlocListener<ProfileDataBloc, ProfileDataState>(
          listener: (context, state) {
            if (state.imageStatus == ImageStatus.success) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    margin: const EdgeInsets.all(4),
                    content: const Text(
                      'Фото профиля успешно изменено.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
            }
            if (state.imageStatus == ImageStatus.failure) {
              warningDialog(
                context: context,
                title: 'Ошибка',
                content:
                    'Не удалось сохранить изменения. Проверьте подключение к интернету или попробуйте позже.',
              );
            }
          },
          child: BlocBuilder<ProfileDataBloc, ProfileDataState>(
            buildWhen: (previous, current) =>
                previous.imageStatus != current.imageStatus,
            builder: (context, state) {
              return SheetAvatarContent(
                state: state,
              );
            },
          ),
        ),
      );
    },
  ).whenComplete(
    () => context.read<ProfileDataBloc>().add(ProfileDataInputClosed()),
  );
}

/// Контент ModalBottomSheet для редактирования аватара пользователя
class SheetAvatarContent extends StatelessWidget {
  final ProfileDataState state;
  const SheetAvatarContent({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Выберите фото профиля:',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            _AvatarPreview(pickedImageFile: state.pickedImageFile),
            _Actions(),
            _SubmitButton(imageStatus: state.imageStatus),
          ],
        ),
      ),
    );
  }
}

/// Кнопка отправки запроса на изменение аватара
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.imageStatus});
  final ImageStatus imageStatus;
  @override
  Widget build(BuildContext context) {
    if (imageStatus == ImageStatus.inProgrerss)
      return SizedBox(
        height: 50,
        width: 50,
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColorDark,
        ),
      );
    else
      // Если фото выбрано условие пройдет и кнопка будет активна
      return ElevatedButton(
        onPressed: imageStatus == ImageStatus.changed
            ? () {
                context.read<ProfileDataBloc>().add(
                      ProfileDataPickedImageSubmitted(),
                    );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColorDark,
          disabledBackgroundColor: Colors.black12,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text(
          'Сохранить',
        ),
      );
  }
}

/// Кнопки [ImagePicker]'а
class _Actions extends StatelessWidget {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Кнопка выбора изображения из галереи
          InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            onTap: () => _pickImageFromGallery(context),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.photo_rounded,
                    size: 30,
                    color: Theme.of(context).focusColor,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Галерея',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ],
              ),
            ),
          ),
          // Кнопка выбора изорбражения с камеры устроства
          InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            onTap: () => _pickImageFromCamera(context),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.camera_rounded,
                    size: 30,
                    color: Theme.of(context).focusColor,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Камера',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Превью нового аватара, используется выбранная пользователем фотография или заглушка [AssetImage]
class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({required this.pickedImageFile});
  final PickedImage pickedImageFile;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.transparent,
        foregroundImage: pickedImageFile != PickedImage.empty
            ? FileImage(
                File(pickedImageFile.photo!.path),
              )
            : const AssetImage('assets/empty_avatar.png') as ImageProvider,
      ),
    );
  }
}
