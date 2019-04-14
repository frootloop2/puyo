import 'dart:html';

import 'package:puyo/src/core/model/state.dart';
import 'package:puyo/src/shell/runner.dart';
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

main() {
  WebSocketChannel channel =
      HtmlWebSocketChannel.connect('ws://${window.location.host}/test');
  channel.stream.listen((message) {
    print(message);
  });
  channel.sink.add('hello websocket');

  Runner().run(initialState);
}
