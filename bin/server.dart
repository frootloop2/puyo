import 'package:appengine/appengine.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

main() async {
  await runAppEngine((request) {
    if (request.uri.path == '/test') {
      handleRequest(request, webSocketHandler((WebSocketChannel webSocket) {
        webSocket.stream.listen((message) {
          webSocket.sink.add("echo $message");
        });
      }));
    } else {
      handleRequest(request,
          createStaticHandler('./build', defaultDocument: 'index.html'));
    }
  });
}
