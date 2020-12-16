import 'package:json_api/handler.dart';
import 'package:test/test.dart';

void main() {
  test('Logging handler can log', () async {
    String? loggedRequest;
    String? loggedResponse;

    final handler =
        LoggingHandler(AsyncHandler.lambda((String s) async => s.toUpperCase()),
            onRequest: (String rq) {
      loggedRequest = rq;
    }, onResponse: (String rs) {
      loggedResponse = rs;
    });
    expect(await handler.call('foo'), 'FOO');
    expect(loggedRequest, 'foo');
    expect(loggedResponse, 'FOO');
  });
}
