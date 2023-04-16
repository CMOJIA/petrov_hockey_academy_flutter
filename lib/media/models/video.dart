import 'package:equatable/equatable.dart';

class Video extends Equatable {
  const Video({
    required this.title,
    required this.author,
    required this.group,
    required this.isPublic,
    this.publishedDt,
  });

  final String title;

  final String author;

  final String group;

  final int isPublic;

  final DateTime? publishedDt;

  @override
  List<Object> get props => [
        title,
        author,
        group,
        isPublic,
        publishedDt ?? '',
      ];
}
