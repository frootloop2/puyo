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

Game game = Game((b) => b.states.addAll([initialState, initialState]));

main() async {
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
}

void registerPlayer(WebSocketChannel webSocket) {
  final int playerId = playerConnectionsByPlayerId.containsKey(0) ? 1 : 0;
  playerConnectionsByPlayerId[playerId] = webSocket;

  // Push the current state so client has something to draw even if no inputs
  // have been received since they connected.
  pushGame(game, [webSocket]);

  webSocket.stream.listen((inputString) {
    final Input input = parseInput(inputString);

    // TODO: this is race condition
    game = update(game, playerId, input);

    pushGame(
        game,
        []
          ..addAll(playerConnectionsByPlayerId.values)
          ..addAll(spectatorConnections));
  }, onDone: () {
    playerConnectionsByPlayerId.remove(playerId);
  });
}

void registerSpectator(WebSocketChannel webSocket) {
  spectatorConnections.add(webSocket);
  webSocket.stream.listen((message) {},
      onDone: () => spectatorConnections.remove(webSocket));

  // Push the current state so client has something to draw even if no inputs
  // have been received since they connected.
  pushGame(game, [webSocket]);
}

void pushGame(Game game, Iterable<WebSocketChannel> webSockets) {
  final String serializedGame = serializeGame(game);
  webSockets.forEach((webSocket) => webSocket.sink.add(serializedGame));
}

String serializeGame(Game game) => json.encode(serializers.serialize(game));

Input parseInput(String inputString) =>
    Input.values.firstWhere((e) => e.toString() == inputString);

Game update(Game game, int stateIndexToUpdate, Input input) {
  State stateToUpdate = game.states[stateIndexToUpdate];
  State newState;
  switch (input) {
    case Input.moveLeft:
      newState = moveLeft(stateToUpdate);
      break;
    case Input.moveRight:
      newState = moveRight(stateToUpdate);
      break;
    case Input.rotateClockwise:
      newState = rotateClockwise(stateToUpdate);
      break;
    case Input.rotateCounterclockwise:
      newState = rotateCounterclockwise(stateToUpdate);
      break;
    case Input.drop:
      newState = allChains(drop(stateToUpdate));
      break;
  }

  return game.rebuild((b) => b.states[stateIndexToUpdate] = newState);
}
