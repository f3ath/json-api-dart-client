import 'dart:io';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/_testing/in_memory_repo.dart';
import 'package:json_api/src/_testing/json_api_server.dart';
import 'package:json_api/src/_testing/repository.dart';
import 'package:json_api/src/_testing/repository_controller.dart';
import 'package:json_api/src/_testing/try_catch_handler.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  final host = 'localhost';
  final port = 8080;
  final resources = ['colors'];
  final handler = DemoHandler(
      types: resources,
      onRequest: (r) => print('${r.method.toUpperCase()} ${r.uri}'),
      onResponse: (r) => print('${r.statusCode}'));
  final server = JsonApiServer(handler, host: host, port: port);
  ProcessSignal.sigint.watch().listen((event) async {
    await server.stop();
    exit(0);
  });
  await server.start();
  print('The server is listening at $host:$port.'
      ' Try opening the following URL(s) in your browser:');
  resources.forEach((resource) {
    print('http://$host:$port/$resource');
  });
}

class DemoHandler extends LoggingHandler {
  DemoHandler({
    Iterable<String> types = const ['users', 'posts', 'comments'],
    Function(HttpRequest request)? onRequest,
    Function(HttpResponse response)? onResponse,
  }) : super(
            TryCatchHandler(
                Router(RepositoryController(InMemoryRepo(types), Uuid().v4),
                    StandardUriDesign.matchTarget),
                onError: convertError),
            onRequest: onRequest,
            onResponse: onResponse);
}

Future<HttpResponse> convertError(dynamic error) async {
  if (error is MethodNotAllowed) {
    return Response.methodNotAllowed();
  }
  if (error is UnmatchedTarget) {
    return Response.badRequest();
  }
  if (error is CollectionNotFound) {
    return Response.notFound(
        OutboundErrorDocument([ErrorObject(title: 'CollectionNotFound')]));
  }
  if (error is ResourceNotFound) {
    return Response.notFound(
        OutboundErrorDocument([ErrorObject(title: 'ResourceNotFound')]));
  }
  if (error is RelationshipNotFound) {
    return Response.notFound(
        OutboundErrorDocument([ErrorObject(title: 'RelationshipNotFound')]));
  }
  return Response(500,
      document: OutboundErrorDocument([
        ErrorObject(
            title: 'Error: ${error.runtimeType}', detail: error.toString())
      ]));
}
