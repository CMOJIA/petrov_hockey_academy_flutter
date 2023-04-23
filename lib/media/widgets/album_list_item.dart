import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petrov_hockey_academy_flutter/media/media.dart';

/// Виджет карточки Альбома
class AlbumListItem extends StatelessWidget {
  const AlbumListItem({super.key, required Album album}) : _album = album;

  final Album _album;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _BluredPhoto(
          album: _album,
        ),
        _AlbumInfo(
          album: _album,
        )
      ],
    );
  }
}

/// Фото и [ImageFiltered]
class _BluredPhoto extends StatelessWidget {
  const _BluredPhoto({required this.album});
  final Album album;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(20),
      ),
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: ColoredBox(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
              image: album.firstPhoto == null
                  ? const DecorationImage(
                      image: AssetImage('assets/no_image.png'),
                      fit: BoxFit.cover,
                    )
                  : DecorationImage(
                      image: NetworkImage('${album.path}/${album.firstPhoto}'),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Текстовая информация об альбоме
class _AlbumInfo extends StatelessWidget {
  const _AlbumInfo({required this.album});
  final Album album;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        color: Colors.black.withOpacity(0.4),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Заголовок
              SizedBox(
                width: double.infinity,
                child: Text(
                  album.title.toString(),
                  style: TextStyle(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Группа
              SizedBox(
                width: double.infinity,
                child: Text(
                  album.group,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),

              // Статус
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 5,
                    child: Text(
                      album.isPublic == 0
                          ? 'Создан'
                          : album.isPublic == 1
                              ? 'Опубликован'
                              : album.isPublic == 3
                                  ? 'На модерации'
                                  : 'Отклонен',
                      style: Theme.of(context).textTheme.bodySmall,
                      softWrap: false,
                    ),
                  ),

                  // Дата публикации если опубликован
                  if (album.isPublic == 1)
                    Flexible(
                      flex: 4,
                      child: Text(
                        DateFormat('dd/MM/yy').format(album.publishedDt!),
                        style: Theme.of(context).textTheme.bodySmall,
                        softWrap: false,
                      ),
                    )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
