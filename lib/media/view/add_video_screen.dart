import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petrov_hockey_academy_flutter/universal/universal.dart';
import 'package:petrov_hockey_academy_flutter/media/media.dart';
import 'package:petrov_hockey_academy_flutter/profile_data/profile_data.dart';
import 'package:formz/formz.dart';

/// Страница добавление видео, дизайн эскпиремнтальный
class AddVideoScreen extends StatelessWidget {
  const AddVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MediaBloc, MediaState>(
      listener: (context, state) {
        if (state.formzStatus == FormzStatus.submissionFailure) {
          warningDialog(
            context: context,
            title: 'Ошибка',
            content:
                'Не удалось загрузить видео. Проверьте подключение к интернету или попробуйте позже.',
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
                  'Видео успешно загружено',
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Создание видео',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    _VideoTitleInput(),
                    GroupSelectionDropdownButton(),
                    const SizedBox(
                      height: 8,
                    ),
                    Author(),
                    _UrlInput(),
                    // Примечание к ссылкам
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Поддерживаются ссылки на следующие сервисы:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    // Список поддерживаемых источников
                    _Sources(),
                    // Примечание по поиску ссылки на видео из разрешенных источников
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'Откройте видео в одном из перечисленных сервисов и получите ссылку, нажав кнопку ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            TextSpan(
                              text: '"Поделиться".',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    _SubmitButton(),
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
          Navigator.pop(context);
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

/// [TextField] заголовка видео
class _VideoTitleInput extends StatelessWidget {
  const _VideoTitleInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MediaBloc, MediaState>(
      buildWhen: (previous, current) =>
          previous.inputVideoTitle != current.inputVideoTitle,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
          child: SizedBox(
            height: 95,
            child: TextField(
              onChanged: (title) => context.read<MediaBloc>()
                ..add(MediaVideoTitleInputChanged(title)),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 255,
              cursorColor: Colors.white70,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
              key: const Key('videoTitle_inputField_textField'),
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
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
                errorText: state.inputVideoTitle.invalid
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

/// [TextField] ссылки на видео
class _UrlInput extends StatelessWidget {
  const _UrlInput();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MediaBloc, MediaState>(
      buildWhen: (previous, current) => previous.inputUrl != current.inputUrl,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 8,
            left: 16,
            right: 16,
          ),
          child: SizedBox(
            height: 95,
            child: TextField(
              onChanged: (url) =>
                  context.read<MediaBloc>()..add(MediaUrlInputChanged(url)),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 255,
              cursorColor: Theme.of(context).scaffoldBackgroundColor,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
              key: const Key('url_inputField_textField'),
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white70,
                    width: 2,
                  ),
                ),
                counterText: '',
                labelText: 'Ссылка',
                labelStyle: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
                errorText:
                    state.inputUrl.invalid ? 'Неверный формат ссылки' : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Информация о разрешенных сервисах с которых можно вставлять ссылку на видео
///
/// Пробное использвание [TextSpan]
class _Sources extends StatelessWidget {
  const _Sources();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        child: Text.rich(
          TextSpan(
            children: [
              // VK
              WidgetSpan(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: const Color.fromARGB(
                      255,
                      0,
                      119,
                      255,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 2,
                  ),
                  child: const Text(
                    '''VK''',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const TextSpan(
                text: ', ',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              // YouTube
              const TextSpan(
                text: '''You''',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              WidgetSpan(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: const Color.fromARGB(255, 255, 0, 0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 2,
                  ),
                  child: const Text(
                    'Tube',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const TextSpan(
                text: ', ',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              // Rutube
              const TextSpan(
                text: 'RUTUBE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const TextSpan(
                text: ', ',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              // Vimeo
              const TextSpan(
                text: 'Vimeo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Кнопка отправки запроса на загрузку видео
class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    final stateProfileData = context.watch<ProfileDataBloc>().state;
    return BlocBuilder<MediaBloc, MediaState>(
      buildWhen: (previous, current) =>
          previous.formzStatus != current.formzStatus,
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
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: state.formzStatus.isValidated
                  ? () {
                      context.read<MediaBloc>().add(
                            MediaVideoSubmitted(
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
                foregroundColor: Colors.white70,
              ),
              child: const Text(
                'Создать',
              ),
            ),
          );
      },
    );
  }
}
