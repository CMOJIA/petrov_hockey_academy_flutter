import 'package:get_it/get_it.dart';
import 'package:petrov_hockey_academy_flutter/graphQL/graphql_service.dart';
import 'package:petrov_hockey_academy_flutter/graphQL/queries.dart' as query;
import 'package:petrov_hockey_academy_flutter/media/media.dart';
import 'package:http/http.dart' show MultipartFile;

final getIt = GetIt.instance;

/// Репозиторий для отправки и получения данных связанных с медиа
class MediaRepository {
  MediaRepository();

  /// Отправка запроса на добавление  видео
  Future<bool?> addVideo({
    required String title,
    required String author,
    required int groupId,
    required String url,
  }) async {
    try {
      final response = await getIt<GraphQLService>().performMutation(
        query.addVideo,
        variables: {
          'title': title,
          'author': author,
          'group_id': groupId,
          'url': url,
        },
      );
      return response.data?['addVideo'];
    } catch (_) {
      rethrow;
    }
  }

  /// Отправка запроса на добавление  альбома
  Future<int?> addAlbum({
    required String title,
    required String author,
    required int groupId,
    required List<MultipartFile> files,
  }) async {
    try {
      final response = await getIt<GraphQLService>().performMutation(
        query.addAlbum,
        variables: {
          'title': title,
          'author': author,
          'group_id': groupId,
          'files': files,
        },
      );

      return response.data?['addAlbum'];
    } catch (_) {
      rethrow;
    }
  }

  /// Отправка запроса на получение списка видео.
  ///
  /// Перебираю список и создаю для каждого экземпляр класса [Video].
  Future<List<Video>> getVideos({required int videosPage}) async {
    try {
      final response = await getIt<GraphQLService>().performQuery(
        query.getVideos,
        variables: {'page': videosPage},
      );

      // Если видео нет
      if (((response.data?['clientSpace'] as Map<String, dynamic>)['video']
              as Map<String, dynamic>)['data'] ==
          null) {
        return [];
      }

      final data =
          ((response.data?['clientSpace'] as Map<String, dynamic>)['video']
              as Map<String, dynamic>)['data'] as List;

      return data.map((dynamic json) {
        final map = json as Map<String, dynamic>;
        return Video(
          author: map['author'] as String,
          title: map['title'] as String,
          isPublic: map['is_public'] as int,
          publishedDt: DateTime.tryParse(map['published_dt'].toString()),
          group: (map['group'] as Map<String, dynamic>)['title'] as String,
        );
      }).toList();
    } catch (_) {
      rethrow;
    }
  }

  /// Отправка запроса на получение списка альбомов.
  ///
  /// Альбомы получаю в виде списка,
  /// прохожу по каждому элементу и создаю экземпляр класса [Album].
  Future<List<Album>> getAlbums({required int albumsPage}) async {
    try {
      final response = await getIt<GraphQLService>().performQuery(
        query.getAlbums,
        variables: {'page': albumsPage},
      );

      // Если альбомов нет
      if (((response.data?['clientSpace'] as Map<String, dynamic>)['album']
              as Map<String, dynamic>)['data'] ==
          null) {
        return [];
      }

      final data =
          ((response.data?['clientSpace'] as Map<String, dynamic>)['album']
              as Map<String, dynamic>)['data'] as List;
      return data.map((dynamic json) {
        final map = json as Map<String, dynamic>;

        return Album(
          author: map['author'] as String,
          title: map['title'] as String,
          isPublic: map['is_public'] as int,
          publishedDt: DateTime.tryParse(map['published_dt'].toString()),
          group: (map['group'] as Map<String, dynamic>)['title'] as String,
          firstPhoto: (map['photos'] as List).isEmpty
              ? null
              : ((map['photos'] as List).first as Map<String, dynamic>)['image']
                  as String,
          path: map['path'] as String,
        );
      }).toList();
    } catch (_) {
      rethrow;
    }
  }
}
