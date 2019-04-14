import 'dart:convert';
import 'dart:html';

import 'package:puyo/src/client/renderer.dart';
import 'package:puyo/src/core/model/game.dart';
import 'package:puyo/src/core/model/input.dart';
import 'package:puyo/src/core/model/serializers.dart';
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const Map<int, InputType> inputTypeByKeyCode = {
  KeyCode.LEFT: InputType.moveLeft,
  KeyCode.RIGHT: InputType.moveRight,
  KeyCode.X: InputType.rotateClockwise,
  KeyCode.Z: InputType.rotateCounterclockwise,
  KeyCode.SPACE: InputType.drop
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
    if (!inputTypeByKeyCode.containsKey(e.keyCode)) {
      return;
    }
    // these will be ignored if client is only a spectator, but there is
    // currently no way of knowing if that is the case.
    webSocketChannel.sink.add('${inputTypeByKeyCode[e.keyCode]}');
  });
}
