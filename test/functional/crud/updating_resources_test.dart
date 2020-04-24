import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/in_memory_repository.dart';
import 'package:json_api/src/server/json_api_server.dart';
import 'package:json_api/src/server/repository_controller.dart';
import 'package:test/test.dart';

import '../../helper/expect_resources_equal.dart';
import 'seed_resources.dart';

void main() async {
  JsonApiServer server;
  JsonApiClient client;
  final host = 'localhost';
  final port = 80;
  final base = Uri(scheme: 'http', host: host, port: port);
  final urls = StandardRouting(base);

  setUp(() async {
    final repository =
        InMemoryRepository({'books': {}, 'people': {}, 'companies': {}});
    server = JsonApiServer(RepositoryController(repository));
    client = JsonApiClient(server, urls);

    await seedResources(client);
  });

  test('200 OK', () async {
    final r = await client.updateResource(Resource('books', '1', attributes: {
      'title': 'Refactoring. Improving the Design of Existing Code',
      'pages': 448
    }, toOne: {
      'publisher': null
    }, toMany: {
      'authors': [Identifier('people', '1')],
      'reviewers': [Identifier('people', '2')]
    }));
    expect(r.isSuccessful, isTrue);
    expect(r.http.statusCode, 200);
    expect(r.http.headers['content-type'], Document.contentType);
    expect(r.decodeDocument().data.unwrap().attributes['title'],
        'Refactoring. Improving the Design of Existing Code');
    expect(r.decodeDocument().data.unwrap().attributes['pages'], 448);
    expect(
        r.decodeDocument().data.unwrap().attributes['ISBN-10'], '0134757599');
    expect(r.decodeDocument().data.unwrap().toOne['publisher'], isNull);
    expect(r.decodeDocument().data.unwrap().toMany['authors'],
        equals([Identifier('people', '1')]));
    expect(r.decodeDocument().data.unwrap().toMany['reviewers'],
        equals([Identifier('people', '2')]));

    final r1 = await client.fetchResource('books', '1');
    expectResourcesEqual(
        r1.decodeDocument().data.unwrap(), r.decodeDocument().data.unwrap());
  });

  test('204 No Content', () async {
    final r = await client.updateResource(Resource('books', '1'));
    expect(r.isSuccessful, isTrue);
    expect(r.isEmpty, isTrue);
    expect(r.http.statusCode, 204);
  });

  test('404 on the target resource', () async {
    final r = await client.updateResource(Resource('books', '42'));
    expect(r.isSuccessful, isFalse);
    expect(r.http.statusCode, 404);
    expect(r.http.headers['content-type'], Document.contentType);
    expect(r.decodeDocument().data, isNull);
    final error = r.decodeDocument().errors.first;
    expect(error.status, '404');
    expect(error.title, 'Resource not found');
    expect(error.detail, "Resource '42' does not exist in 'books'");
  });

  test('409 when the resource type does not match the collection', () async {
    final r = await client.send(
        Request.updateResource(
            Document(ResourceData.fromResource(Resource('books', '1')))),
        urls.resource('people', '1'));
    expect(r.isSuccessful, isFalse);
    expect(r.http.statusCode, 409);
    expect(r.http.headers['content-type'], Document.contentType);
    expect(r.decodeDocument().data, isNull);
    final error = r.decodeDocument().errors.first;
    expect(error.status, '409');
    expect(error.title, 'Invalid resource type');
    expect(error.detail, "Type 'books' does not belong in 'people'");
  });
}
