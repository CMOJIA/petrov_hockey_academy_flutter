import 'package:equatable/equatable.dart';

class Group extends Equatable {
  const Group({
    required this.title,
    required this.groupId,
  });

  final String title;

  final String groupId;

  @override
  List<Object> get props => [title, groupId];
}
