import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:flutter/services.dart';
import 'package:petrov_hockey_academy_flutter/universal/universal.dart';
import 'package:petrov_hockey_academy_flutter/media/media.dart';
import 'package:petrov_hockey_academy_flutter/profile_data/profile_data.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

/// Страница добавления фотоальбома.
class AddAlbumScreen extends StatelessWidget {
  const AddAlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MediaBloc, MediaState>(
      listener: (context, state) {
        if (state.formzStatus == FormzStatus.submissionFailure) {
          warningDialog(
            context: context,
            title: 'Ошибка',
            content:
                'Не удалось загрузить альбом. Проверьте подключение к интернету или попробуйте позже.',
          );
        }
        if (state.formzStatus == FormzStatus.submissionSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                margin: EdgeInsets.all(4),
                content: Text(
                  'Альбом успешно загружен',
                ),
              ),
            );
        }
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          // Экспериментальный вид с градиентом
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColorDark,
              Theme.of(context).primaryColor.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            tileMode: TileMode.mirror,
          ),
        ),
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BackButton(),
                    const SizedBox(
                      height: 8,
                    ),
                    // Заголовок страницы
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Создание альбома',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    _AlbumTitleInput(),
                    GroupSelectionDropdownButton(),
                    const SizedBox(
                      height: 8,
                    ),
                    Author(),
                    const SizedBox(
                      height: 16,
                    ),
                    _PhotoSelection(),
                    _SubmitButton(),
                    _AlbumPreview(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Кнопка назад [TextButton]
class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
        ),
        label: const Text(
          'Назад',
        ),
      ),
    );
  }
}

/// [TextField] заголовка альбома
class _AlbumTitleInput extends StatelessWidget {
  const _AlbumTitleInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MediaBloc, MediaState>(
      buildWhen: (previous, current) =>
          previous.inputAlbumTitle != current.inputAlbumTitle,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
          child: SizedBox(
            height: 95,
            child: TextField(
              onChanged: (title) {
                print(title);
                context.read<MediaBloc>()
                  ..add(MediaAlbumTitleInputChanged(title));
              },
              maxLength: 255,
              cursorColor: Colors.white70,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white70,
                    width: 2,
                  ),
                ),
                counterText: '',
                labelText: 'Название',
                labelStyle: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
                errorText: state.formzStatus.isInvalid
                    ? 'Минимум 3 символа, только буквы и цифры'
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Кнопка выбора фотографий
class _PhotoSelection extends StatelessWidget {
  const _PhotoSelection();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).primaryColor,
      highlightColor: Colors.transparent,
      child: Container(
        color: Colors.black12,
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Выбрать фотографии',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
              textAlign: TextAlign.left,
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
            )
          ],
        ),
      ),
      onTap: () async {
        final _images = await AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            maxAssets: 10,
            requestType: RequestType.image,
            gridCount: 3,
            pageSize: 75,
            themeColor: Theme.of(context).primaryColor,
            textDelegate: const RussianAssetPickerTextDelegate(),
          ),
        );
        if (_images != null) {
          context.read<MediaBloc>().add(MediaImagesPicked(_images));
        }
      },
    );
  }
}

/// Кнопка отправки запроса на загрузку альбмоа
class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    final stateProfileData = context.watch<ProfileDataBloc>().state;
    return BlocBuilder<MediaBloc, MediaState>(
      buildWhen: (previous, current) =>
          previous.formzStatus != current.formzStatus ||
          previous.images != current.images,
      builder: (context, state) {
        if (state.formzStatus == FormzStatus.submissionInProgress)
          return Center(
            child: Container(
              height: 50,
              width: 50,
              margin: const EdgeInsets.all(16),
              child: const CircularProgressIndicator(
                color: Colors.white70,
              ),
            ),
          );
        else
          return Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  state.formzStatus.isValidated && state.images.isNotEmpty
                      ? () {
                          context.read<MediaBloc>().add(
                                MediaAlbumSubmitted(
                                  '''${stateProfileData.profileData.middleName} '''
                                  '''${stateProfileData.profileData.firstName.substring(0, 1).toUpperCase()}.'''
                                  '''${stateProfileData.profileData.lastName.substring(0, 1).toUpperCase()}.''',
                                ),
                              );
                        }
                      : null,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  disabledBackgroundColor: Colors.black12,
                  backgroundColor:
                      Theme.of(context).primaryColorDark.withOpacity(0.6),
                  foregroundColor: Colors.white70),
              child: const Text(
                'Создать',
              ),
            ),
          );
      },
    );
  }
}

/// Карточка с превью альбома
class _AlbumPreview extends StatelessWidget {
  const _AlbumPreview();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MediaBloc, MediaState>(
      buildWhen: (previous, current) => previous.images != current.images,
      builder: (context, state) {
        if (state.images.isNotEmpty)
          return Card(
            color: Colors.white10,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                    child: Image(
                      image: AssetEntityImageProvider(
                        state.images[index],
                        isOriginal: false,
                      ),
                      fit: BoxFit.cover,
                    ),
                  );
                },
                itemCount: state.images.length,
              ),
            ),
          );
        else
          return SizedBox();
      },
    );
  }
}
