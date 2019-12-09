import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/response.dart';
import 'package:json_api/src/server/server_document_factory.dart';

class MetaResponse extends Response {
  final Map<String, Object> meta;

  MetaResponse(this.meta) : super(200);

  @override
  Document buildDocument(ServerDocumentFactory builder, Uri self) =>
      builder.makeMetaDocument(meta);
}
