import 'dart:ui' show ImageFilter;

import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petrov_hockey_academy_flutter/media/media.dart';
import 'package:petrov_hockey_academy_flutter/universal/universal.dart';

/// Экран просмотра списка фотоальбомов [Album] и видео [Video] пользователя
class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final scrollController = ScrollController();
  final List<String> filterList = const [
    'Альбомы',
    'Видео',
    'Опубликован',
    'Отклонен',
  ];

  List<String> selectedFiltertList = ['Альбомы'];

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    final _displaySize = MediaQuery.of(context).size;

    /// Сетка альбомов
    Widget _showAlbums(List<Album> albums, bool hasReachedMax) {
      return albums.isEmpty
          ? Expanded(
              child: EmptyContent(
                value:
                    'У вас еще нет альбомов соответствующих заданным парметрам.',
                size: _displaySize,
              ),
            )
          : _AlbumsGrid(
              albums: albums,
              hasReachedMax: hasReachedMax,
              scrollController: scrollController,
              selectedFiltertList: selectedFiltertList,
            );
    }

    /// Список Видео
    Widget _showVideos(List<Video> videos, bool hasReachedMax) {
      return videos.isEmpty
          ? Expanded(
              child: EmptyContent(
                value:
                    'У вас еще нет видео соответствующих заданным парметрам.',
                size: _displaySize,
              ),
            )
          : _VideosList(
              hasReachedMax: hasReachedMax,
              scrollController: scrollController,
              selectedFiltertList: selectedFiltertList,
              videos: videos,
            );
    }

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        title: const Text('Ваши медиа'),
      ),
      body: BlocProvider.value(
        value: BlocProvider.of<MediaBloc>(context),
        child: BlocBuilder<MediaBloc, MediaState>(
          builder: (context, state) {
            final _hasReachedAlbumsMax = state.hasReachedAlbumsMax;

            final _hasReachedVideosMax = state.hasReachedVideosMax;

            switch (state.status) {
              case MediaStatus.initial:
                return _StatusScreenShimmer();

              case MediaStatus.failure:
                return _FailureContent(
                  size: _displaySize,
                );

              case MediaStatus.success:
                return Column(
                  children: [
                    // Filter's Chip list
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      height: 50,
                      child: Center(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filterList.length,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) => Padding(
                            padding: index == filterList.length - 1
                                ? const EdgeInsets.symmetric(horizontal: 5)
                                : const EdgeInsets.only(left: 5),
                            child: FilterChip(
                              label: Text(filterList[index]),
                              labelStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: selectedFiltertList
                                        .contains(filterList[index])
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: selectedFiltertList
                                        .contains(filterList[index])
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Colors.black,
                              ),
                              elevation: 2,
                              backgroundColor: Colors.black26,
                              checkmarkColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              selectedColor: Theme.of(context).primaryColor,
                              selected: selectedFiltertList
                                  .contains(filterList[index]),
                              onSelected: (selected) {
                                // Логика, чтобы мог быть выбран фильтр либо Альбомы либо Видео(т.к. имеют разные форматы отображения)
                                //
                                // При этом можно только переключиться с Альбомов на Видео и наоборот, но снять выбор, что отображать - нельзя
                                //
                                // Фильтры: Опубликован, Отклонен можно, как выбирать все сразу, так и не выбирать вовсе
                                setState(() {
                                  // Если уже выбраны "Альбомы" и нажимаю на "Видео"
                                  if (selectedFiltertList.contains('Альбомы') &&
                                      filterList[index] == 'Видео') {
                                    selectedFiltertList
                                      ..remove('Альбомы')
                                      ..add(filterList[index]);
                                  }
                                  // Если уже выбраны "Видео" и нажимаю на "Альбомы"
                                  else if (selectedFiltertList
                                          .contains('Видео') &&
                                      filterList[index] == 'Альбомы') {
                                    selectedFiltertList
                                      ..remove('Видео')
                                      ..add(filterList[index]);
                                  }
                                  // Если уже выбраны "Альбомы" и нажимаю на "Альбомы" ничего не делать
                                  else if (selectedFiltertList
                                          .contains('Альбомы') &&
                                      filterList[index] == 'Альбомы') {
                                  }
                                  // Если уже выбраны "Видео" и нажимаю на "Видео" ничего не делать
                                  else if (selectedFiltertList
                                          .contains('Видео') &&
                                      filterList[index] == 'Видео') {
                                  }
                                  // Для всех остальных фильтров
                                  else {
                                    selectedFiltertList
                                            .contains(filterList[index])
                                        ? selectedFiltertList
                                            .remove(filterList[index])
                                        : selectedFiltertList
                                            .add(filterList[index]);
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Логика отображения списка по выбранным фильтрам
                    // Могут быть другие статусы помимо "Отклонен" и "Опубликован", но они не нужны
                    if (selectedFiltertList.contains('Альбомы'))
                      // если альбом и опубликован
                      if (selectedFiltertList.contains('Опубликован'))
                        _showAlbums(
                          state.albums.where((e) => e.isPublic == 1).toList(),
                          _hasReachedAlbumsMax,
                        )
                      // если альбом и отклонен
                      else if (selectedFiltertList.contains('Отклонен'))
                        _showAlbums(
                          state.albums.where((e) => e.isPublic == 4).toList(),
                          _hasReachedAlbumsMax,
                        )
                      // если альбом и отклонен или опубликован
                      else if (selectedFiltertList.contains('Отклонен') &&
                          selectedFiltertList.contains('Опубликован'))
                        _showAlbums(
                          state.albums
                              .where((e) => e.isPublic == 1 || e.isPublic == 4)
                              .toList(),
                          _hasReachedAlbumsMax,
                        )
                      else
                        _showAlbums(
                          state.albums,
                          _hasReachedAlbumsMax,
                        ),
                    if (selectedFiltertList.contains('Видео'))
                      // если видео и опубликовано
                      if (selectedFiltertList.contains('Опубликован'))
                        _showVideos(
                          state.videos.where((e) => e.isPublic == 1).toList(),
                          _hasReachedVideosMax,
                        )
                      // если видео и отклонено
                      else if (selectedFiltertList.contains('Отклонен'))
                        _showVideos(
                          state.videos.where((e) => e.isPublic == 4).toList(),
                          _hasReachedVideosMax,
                        )
                      // если видео и опубликовано и отклонено
                      else if (selectedFiltertList.contains('Отклонен') &&
                          selectedFiltertList.contains('Опубликован'))
                        _showVideos(
                          state.videos
                              .where((e) => e.isPublic == 1 || e.isPublic == 4)
                              .toList(),
                          _hasReachedVideosMax,
                        )
                      else
                        _showVideos(
                          state.videos,
                          _hasReachedVideosMax,
                        ),
                  ],
                );
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// В зависимости от выбранного фильтра будут подгружаться последующие альбомы или видео.
  void _onScroll() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (selectedFiltertList.contains('Альбомы'))
        context.read<MediaBloc>().add(MediaAlbumLoadedMore());
      if (selectedFiltertList.contains('Видео'))
        context.read<MediaBloc>().add(MediaVideoLoadedMore());
    }
  }
}

/// Контент когда загрузка данных завершилась ошибкой
class _FailureContent extends StatelessWidget {
  const _FailureContent({required this.size});
  final Size size;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.1,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Ошибка загрузки.\nПроверьте интернет-подключение или повторите попытку позже.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          RefreshButton(
            onTap: () {
              context.read<MediaBloc>().add(MediaFetched());
            },
            authenticationRepository: context.read<AuthenticationRepository>(),
          ),
        ],
      ),
    );
  }
}

/// Список видео [ListView]
class _VideosList extends StatelessWidget {
  const _VideosList({
    required this.videos,
    required this.selectedFiltertList,
    required this.hasReachedMax,
    required this.scrollController,
  });
  final List<Video> videos;
  final List<String> selectedFiltertList;
  final bool hasReachedMax;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return index >= videos.length
              // Если выбран фильтр "Опубликован" или "Отклонен", список прогружаться дальше не будет
              ? (selectedFiltertList.contains('Видео') &&
                          (selectedFiltertList.contains('Опубликован')) ||
                      selectedFiltertList.contains('Отклонен'))
                  ? null
                  // Иначе показывать CircularProgressIndicator
                  : const Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
              : VideoListItem(video: videos[index]);
        },
        itemCount: hasReachedMax ? videos.length : videos.length + 1,
        controller: scrollController,
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            indent: 16,
            endIndent: 16,
            thickness: 1,
            color: Theme.of(context).primaryColorDark.withOpacity(0.5),
          );
        },
      ),
    );
  }
}

/// Таблица альбомов [GridView]
class _AlbumsGrid extends StatelessWidget {
  const _AlbumsGrid({
    required this.albums,
    required this.selectedFiltertList,
    required this.hasReachedMax,
    required this.scrollController,
  });
  final List<Album> albums;
  final List<String> selectedFiltertList;
  final bool hasReachedMax;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2 / 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (BuildContext context, int index) {
            return index >= albums.length
                // Если выбран фильтр "Опубликован" или "Отклонен", список прогружаться дальше не будет
                ? (selectedFiltertList.contains('Альбомы') &&
                            (selectedFiltertList.contains('Опубликован')) ||
                        selectedFiltertList.contains('Отклонен'))
                    ? null
                    // Иначе показывать CircularProgressIndicator
                    : _AlbumCircularIndicator()
                : AlbumListItem(album: albums[index]);
          },
          itemCount: hasReachedMax ? albums.length : albums.length + 1,
          controller: scrollController,
        ),
      ),
    );
  }
}

/// Заглушка показывающая процесс загрузки последующих альбомов.
class _AlbumCircularIndicator extends StatelessWidget {
  const _AlbumCircularIndicator();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Размытый фон
        ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black54,
                  width: 10,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
            ),
          ),
        ),
        // Индикатор загрузки
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
            color: Colors.grey.shade500.withOpacity(0.5),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
}

/// [Shimmer] заглушка прогрузки данных
class _StatusScreenShimmer extends StatelessWidget {
  const _StatusScreenShimmer();

  @override
  Widget build(BuildContext context) {
    final chipHeigth = 22.0;
    final chipWidth = 80.0;
    final color = Colors.grey[400];
    return AbsorbPointer(
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            // список шммеров в форме FilterClip
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: 50,
              child: Center(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 4,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Shimmer.fromColors(
                      baseColor: color!,
                      highlightColor: Colors.grey[300]!,
                      child: FilterChip(
                        label: SizedBox(
                          height: chipHeigth,
                          width: chipWidth,
                        ),
                        onSelected: null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // сетка шиммеров в виде карточек альбомов
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2 / 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Shimmer.fromColors(
                      baseColor: color!,
                      highlightColor: Colors.grey[300]!,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                          color: color,
                        ),
                      ),
                    );
                  },
                  itemCount: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
