import 'dart:async';
import 'dart:convert';

import 'package:appengine/appengine.dart';
import 'package:puyo/src/core/model/game.dart';
import 'package:puyo/src/core/model/input.dart';
import 'package:puyo/src/core/model/serializers.dart';
import 'package:puyo/src/core/model/state.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final Map<int, WebSocketChannel> playerConnectionsByPlayerId = {};
final Set<WebSocketChannel> spectatorConnections = {};
final StreamController<Input> inputStreamController = StreamController();

Game game = Game((b) => b.states.addAll([initialState, initialState]));

main() async {
  inputStreamController.stream.listen((input) {
    game = update(game, input);
    pushGame(
        game,
        []
          ..addAll(playerConnectionsByPlayerId.values)
          ..addAll(spectatorConnections));
  });

  await runAppEngine((request) {
    if (request.uri.path == '/test') {
      handleRequest(request, webSocketHandler(registerWebSocket));
    } else {
      handleRequest(request,
          createStaticHandler('./build', defaultDocument: 'index.html'));
    }
  });
}

void registerWebSocket(WebSocketChannel webSocket) {
  if (playerConnectionsByPlayerId.containsKey(0) &&
      playerConnectionsByPlayerId.containsKey(1)) {
    registerSpectator(webSocket);
  } else {
    registerPlayer(webSocket);
  }

  // Bring new client up to speed
  pushGame(game, [webSocket]);
}

void registerPlayer(WebSocketChannel webSocket) {
  final int playerId = playerConnectionsByPlayerId.containsKey(0) ? 1 : 0;
  playerConnectionsByPlayerId[playerId] = webSocket;

  webSocket.stream.listen((inputTypeString) {
    final InputType inputType = parseInputType(inputTypeString);
    final Input input = Input((b) => b
      ..inputType = inputType
      ..playerId = playerId);
    inputStreamController.sink.add(input);
  }, onDone: () {
    playerConnectionsByPlayerId.remove(playerId);
  });
}

void registerSpectator(WebSocketChannel webSocket) {
  spectatorConnections.add(webSocket);
  webSocket.stream.listen((message) {},
      onDone: () => spectatorConnections.remove(webSocket));
}

void pushGame(Game game, Iterable<WebSocketChannel> webSockets) {
  final String serializedGame = serializeGame(game);
  webSockets.forEach((webSocket) => webSocket.sink.add(serializedGame));
}

String serializeGame(Game game) => json.encode(serializers.serialize(game));

InputType parseInputType(String inputTypeString) =>
    InputType.values.firstWhere((e) => e.toString() == inputTypeString);

Game update(Game game, Input input) {
  State stateToUpdate = game.states[input.playerId];
  State newState;
  switch (input.inputType) {
    case InputType.moveLeft:
      newState = moveLeft(stateToUpdate);
      break;
    case InputType.moveRight:
      newState = moveRight(stateToUpdate);
      break;
    case InputType.rotateClockwise:
      newState = rotateClockwise(stateToUpdate);
      break;
    case InputType.rotateCounterclockwise:
      newState = rotateCounterclockwise(stateToUpdate);
      break;
    case InputType.drop:
      newState = allChains(drop(stateToUpdate));
      break;
  }

  return game.rebuild((b) => b.states[input.playerId] = newState);
}
