import 'dart:html';

import 'package:puyo/src/core/model/state.dart';
import 'package:puyo/src/shell/browser_keyboard_service.dart';
import 'package:puyo/src/shell/system.dart';

class BrowserKeyboardProcessor implements System {
  final BrowserKeyboardService _browserKeyboardService =
      BrowserKeyboardService();

  @override
  State update(State state) {
    _browserKeyboardService.tickFrame();
    if (_browserKeyboardService.isKeyPressedSinceStartOfLastFrame(KeyCode.Z)) {
      state = rotateCounterclockwise(state);
    }
    if (_browserKeyboardService.isKeyPressedSinceStartOfLastFrame(KeyCode.X)) {
      state = rotateClockwise(state);
    }
    if (_browserKeyboardService
        .isKeyPressedSinceStartOfLastFrame(KeyCode.LEFT)) {
      state = moveLeft(state);
    }
    if (_browserKeyboardService
        .isKeyPressedSinceStartOfLastFrame(KeyCode.RIGHT)) {
      state = moveRight(state);
    }
    if (_browserKeyboardService
        .isKeyPressedSinceStartOfLastFrame(KeyCode.SPACE)) {
      state = allChains(drop(state));
    }
    return state;
  }
}
