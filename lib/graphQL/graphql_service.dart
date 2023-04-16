import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:petrov_hockey_academy_flutter/graphQL/secrets.dart';

/// [GraphQLService] используется для отправки запросов и мутаций к API, и возвращает ответ.
///
/// Для зарпосов, которые требуют пользовательского токена
class GraphQLService {
  GraphQLService(this._token) {
    final _httpLink = HttpLink(
      apiUrl,
      defaultHeaders: {
        'Api-Key': apiKey,
        'Authorization': 'Bearer $_token',
      },
    );
    _client = GraphQLClient(
      link: _httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  late GraphQLClient _client;

  final String _token;

  // Инициализациия и отправка запроса
  Future<QueryResult> performQuery(
    String query, {
    required Map<String, dynamic> variables,
  }) async {
    final options = QueryOptions(
      document: gql(query),
      variables: variables,
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await _client.query(options);

    return result;
  }

  // Инициализациия и отправка мутации
  Future<QueryResult> performMutation(
    String mutation, {
    required Map<String, dynamic> variables,
  }) async {
    final options = MutationOptions(
      document: gql(mutation),
      variables: variables,
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await _client.mutate(options);
    return result;
  }
}
