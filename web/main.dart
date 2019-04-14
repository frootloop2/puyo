import 'dart:html';

import 'package:puyo/src/core/model/state.dart';
import 'package:puyo/src/shell/runner.dart';
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

main() {
  final String path = '/test';
  final String connectionType =
      (window.location.hostname == 'localhost') ? 'ws://' : 'wss://';

  WebSocketChannel webSocketChannel = HtmlWebSocketChannel.connect(
      '$connectionType${window.location.host}$path');

  webSocketChannel.stream.listen((message) {
    print(message);
  });
  webSocketChannel.sink.add('hello websocket');

  Runner().run(initialState);
}
