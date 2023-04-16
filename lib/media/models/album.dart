import 'package:equatable/equatable.dart';

class Album extends Equatable {
  const Album({
    required this.title,
    required this.author,
    required this.group,
    required this.isPublic,
    this.publishedDt,
    required this.firstPhoto,
    required this.path,
  });

  final String? title;

  final String? author;

  final String group;

  final int isPublic;

  final DateTime? publishedDt;

  final String? firstPhoto;

  final String path;

  @override
  List<Object> get props => [
        title ?? '',
        author ?? '',
        group,
        isPublic,
        publishedDt ?? '',
        firstPhoto!,
        path,
      ];
}
