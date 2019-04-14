import 'dart:convert';
import 'dart:html';

import 'package:puyo/src/client/renderer.dart';
import 'package:puyo/src/core/model/game.dart';
import 'package:puyo/src/core/model/input.dart';
import 'package:puyo/src/core/model/serializers.dart';
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const Map<int, Input> inputByKeyCode = {
  KeyCode.LEFT: Input.moveLeft,
  KeyCode.RIGHT: Input.moveRight,
  KeyCode.X: Input.rotateClockwise,
  KeyCode.Z: Input.rotateCounterclockwise,
  KeyCode.SPACE: Input.drop
};

const String path = '/test';

main() async {
  final String connectionType =
      (window.location.hostname == 'localhost') ? 'ws://' : 'wss://';

  final Renderer renderer0 = Renderer('canvas0', 6, 12);
  final Renderer renderer1 = Renderer('canvas1', 6, 12);

  final WebSocketChannel webSocketChannel = HtmlWebSocketChannel.connect(
      '$connectionType${window.location.host}$path');

  webSocketChannel.stream.listen((gameString) {
    final Game game = serializers.deserialize(json.decode(gameString));
    renderer0.render(game.states.first);
    renderer1.render(game.states.last);
  });

  window.onKeyDown.listen((KeyboardEvent e) {
    if (!inputByKeyCode.containsKey(e.keyCode)) {
      return;
    }
    webSocketChannel.sink.add('${inputByKeyCode[e.keyCode]}');
  });
}
