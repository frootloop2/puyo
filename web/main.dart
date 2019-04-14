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

  final List<Renderer> renderers = [
    Renderer('canvas0', 6, 12),
    Renderer('canvas1', 6, 12)
  ];
  List<int> renderOrder;

  final WebSocketChannel webSocketChannel = HtmlWebSocketChannel.connect(
      '$connectionType${window.location.host}$path');

  webSocketChannel.stream.listen((gameString) {
    final Game game = serializers.deserialize(json.decode(gameString));

    DivElement playerIdElement = querySelector('#playerId');
    if (playerIdElement.text.isEmpty) {
      playerIdElement.appendText(
          game.playerId == -1 ? 'spectating' : 'player ${game.playerId + 1}');
      renderOrder = game.playerId == 1 ? [1, 0] : [0, 1];
    }

    for (int i = 0; i < renderOrder.length; i++) {
      renderers[i].render(game.states[renderOrder[i]]);
    }
  });

  window.onKeyDown.listen((KeyboardEvent e) {
    if (!inputTypeByKeyCode.containsKey(e.keyCode)) {
      return;
    }
    if (querySelector('#playerId').text == 'spectating') {
      return;
    }

    webSocketChannel.sink.add('${inputTypeByKeyCode[e.keyCode]}');
  });
}
