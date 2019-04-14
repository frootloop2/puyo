import 'dart:convert';

import 'package:appengine/appengine.dart';
import 'package:puyo/src/core/model/input.dart';
import 'package:puyo/src/core/model/serializers.dart';
import 'package:puyo/src/core/model/state.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

main() async {
  const int maxWebSocketConnections = 5;
  int webSocketConnections = 0;

  await runAppEngine((request) {
    if (webSocketConnections < maxWebSocketConnections &&
        request.uri.path == '/test') {
      handleRequest(request, webSocketHandler((WebSocketChannel webSocket) {
        webSocketConnections++;
        State state = initialState;
        webSocket.sink.add(json.encode(serializers.serialize(state)));
        webSocket.stream.listen((inputString) {
          final Input input =
              Input.values.firstWhere((e) => e.toString() == inputString);
          state = update(state, input);
          webSocket.sink.add(json.encode(serializers.serialize(state)));
        }, onDone: () {
          webSocketConnections--;
        });
      }));
    } else {
      handleRequest(request,
          createStaticHandler('./build', defaultDocument: 'index.html'));
    }
  });
}

State update(State state, Input input) {
  switch (input) {
    case Input.moveLeft:
      return moveLeft(state);
    case Input.moveRight:
      return moveRight(state);
    case Input.rotateClockwise:
      return rotateClockwise(state);
    case Input.rotateCounterclockwise:
      return rotateCounterclockwise(state);
    case Input.drop:
      return allChains(drop(state));
    default:
      return state;
  }
}
