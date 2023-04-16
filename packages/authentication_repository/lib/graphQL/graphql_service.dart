import 'package:graphql/client.dart';

/// GraphQLService используется для отправки запросов и мутаций к API, и возвращает ответ.
///
/// В репоозитории GraphQLService отдельный, для запросов где токен пользователя не нужен
class GraphQLService {
  GraphQLService() {
    final httpLink = HttpLink(
      'https://petrovapi.joinsport.io/graphql',
      defaultHeaders: {
        'Api-Key': 'ua6fjo2wkvokuqjz',
      },
    );

    _client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }
  late GraphQLClient _client;

  Future<QueryResult> performQuery(
    String query, {
    required Map<String, dynamic> variables,
  }) async {
    final options = QueryOptions(document: gql(query), variables: variables);
    final result = await _client.query(options);
    return result;
  }

  Future<QueryResult> performMutation(
    String mutation, {
    required Map<String, dynamic> variables,
  }) async {
    final options =
        MutationOptions(document: gql(mutation), variables: variables);
    final result = await _client.mutate(options);
    return result;
  }
}
