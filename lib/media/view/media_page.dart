import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petrov_hockey_academy_flutter/media/media.dart';
import 'package:petrov_hockey_academy_flutter/profile_data/profile_data.dart';
import 'package:petrov_hockey_academy_flutter/transitions/transitions.dart';

/// Страница подменю медиа.
///
/// Переход к странице альбомов/видео или к странице добавления альбома/видео.
class MediaPage extends StatelessWidget {
  const MediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<MediaBloc>(context),
      child: const ElemetsOfMediaPage(),
    );
  }
}

class ElemetsOfMediaPage extends StatelessWidget {
  const ElemetsOfMediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        title: const Text('Добавить медиа'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Card(
            color: Theme.of(context).primaryColorDark,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _StatusButton(),
                  _AddAlbumButton(),
                  _AddVideoButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Кнопка перехода на старниу к списку медиа пользователя
class _StatusButton extends StatelessWidget {
  const _StatusButton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        onTap: () => Navigator.push(
          context,
          SlideRightRoute(
            builder: (
              ctx,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return BlocProvider.value(
                value: BlocProvider.of<MediaBloc>(context)..add(MediaFetched()),
                child: const StatusScreen(),
              );
            },
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.list_rounded,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: 'Статус',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Кнопка перехода на странциу добавления фотоальбома
class _AddAlbumButton extends StatelessWidget {
  const _AddAlbumButton();

  @override
  Widget build(BuildContext context) {
    final groupId = context.select(
      (ProfileDataBloc bloc) => bloc.state.groups.first.groupId,
    );

    return Card(
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        onTap: () => Navigator.push(
          context,
          FadeRoute(
            builder: (
              ctx,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider.value(
                    value: BlocProvider.of<MediaBloc>(context)
                      // ИСПРАВИТЬ ПОЗЖЕ
                      //
                      // Добавляю ивент тут, потому что первый раз при переходе
                      // на старницу добавления альбома или видео не успевал выполниться ивенти и была ошибка.
                      // Выяснить почему.
                      ..add(
                        AddMediaSettedInitialState(
                          int.parse(
                            groupId,
                          ),
                        ),
                      ),
                  ),
                  BlocProvider.value(
                    value: BlocProvider.of<ProfileDataBloc>(
                      context,
                    ),
                  ),
                ],
                child: const AddAlbumScreen(),
              );
            },
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.add_a_photo_rounded,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: 'Добавление фото в медиа',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Кнопка перехода к экрану добавления видео
class _AddVideoButton extends StatelessWidget {
  const _AddVideoButton();

  @override
  Widget build(BuildContext context) {
    final groupId = context.select(
      (ProfileDataBloc bloc) => bloc.state.groups.first.groupId,
    );

    return Card(
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        onTap: () => Navigator.push(
          context,
          FadeRoute(
            builder: (
              ctx,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider.value(
                    value: BlocProvider.of<MediaBloc>(context)
                      // ИСПРАВИТЬ ПОЗЖЕ
                      //
                      // Добавляю ивент тут, потому что первый раз при переходе
                      // на старницу добавления альбома или видео не успевал выполниться ивенти и была ошибка.
                      // Выяснить почему.
                      ..add(
                        AddMediaSettedInitialState(
                          int.parse(groupId),
                        ),
                      ),
                  ),
                  BlocProvider.value(
                    value: BlocProvider.of<ProfileDataBloc>(
                      context,
                    ),
                  ),
                ],
                child: const AddVideoScreen(),
              );
            },
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.videocam_rounded,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: 'Мои тренировки',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
