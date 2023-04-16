import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petrov_hockey_academy_flutter/media/media.dart';

/// Виджет карточки видео
class VideoListItem extends StatelessWidget {
  const VideoListItem({super.key, required this.video});

  final Video video;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Title(
            video: video,
          ),
          const SizedBox(
            height: 10,
          ),
          _Group(
            video: video,
          ),
          const SizedBox(
            height: 10,
          ),
          _Status(
            video: video,
          )
        ],
      ),
    );
  }
}

// Заголовок видео
class _Title extends StatelessWidget {
  const _Title({required this.video});
  final Video video;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          video.title,
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ],
    );
  }
}

// Группа которая связана с этим видео
class _Group extends StatelessWidget {
  const _Group({required this.video});
  final Video video;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            video.group,
            style: const TextStyle(
              fontSize: 16,
              overflow: TextOverflow.fade,
              color: Colors.black54,
            ),
            softWrap: false,
          ),
        ),
      ],
    );
  }
}

// Статус публикации видео
class _Status extends StatelessWidget {
  const _Status({required this.video});
  final Video video;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            video.isPublic == 0
                ? 'Создан'
                : video.isPublic == 1
                    ? 'Опубликован'
                    : video.isPublic == 3
                        ? 'На модерации'
                        : 'Отклонен',
            style: const TextStyle(
              fontSize: 16,
              overflow: TextOverflow.fade,
              color: Colors.black54,
            ),
            softWrap: false,
          ),
        ),
        Flexible(
          child: video.isPublic == 1
              ? Text(
                  DateFormat('dd/MM/yy').format(video.publishedDt!),
                  style: const TextStyle(
                    fontSize: 16,
                    overflow: TextOverflow.fade,
                    color: Colors.black54,
                  ),
                  softWrap: false,
                )
              : const SizedBox(),
        ),
      ],
    );
  }
}
