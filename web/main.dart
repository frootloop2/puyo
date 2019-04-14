import 'dart:convert';
import 'dart:html';

import 'package:puyo/src/core/model/input.dart';
import 'package:puyo/src/core/model/serializers.dart';
import 'package:puyo/src/core/model/state.dart';
import 'package:puyo/src/shell/renderer.dart';
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

main() async {
  final String path = '/test';
  final String connectionType =
      (window.location.hostname == 'localhost') ? 'ws://' : 'wss://';

  final Map<int, Input> inputByKeyCode = {
    KeyCode.LEFT: Input.moveLeft,
    KeyCode.RIGHT: Input.moveRight,
    KeyCode.X: Input.rotateClockwise,
    KeyCode.Z: Input.rotateCounterclockwise,
    KeyCode.SPACE: Input.drop
  };
  final Renderer renderer = Renderer(6, 12);

  final WebSocketChannel webSocketChannel = HtmlWebSocketChannel.connect(
      '$connectionType${window.location.host}$path');

  webSocketChannel.stream.listen((stateString) {
    final State state = serializers.deserialize(json.decode(stateString));
    renderer.render(state);
  });

  window.onKeyDown.listen((KeyboardEvent e) {
    if (!inputByKeyCode.containsKey(e.keyCode)) {
      return;
    }
    webSocketChannel.sink.add('${inputByKeyCode[e.keyCode]}');
  });
}
