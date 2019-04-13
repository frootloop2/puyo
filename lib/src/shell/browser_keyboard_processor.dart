import 'dart:html';

import 'package:puyo/src/core/model/state.dart';
import 'package:puyo/src/shell/browser_keyboard_service.dart';
import 'package:puyo/src/shell/system.dart';

class BrowserKeyboardProcessor implements System {
  static final int _clockwiseKey = KeyCode.X;
  static final int _counterclockwiseKey = KeyCode.Z;
  static final int _leftKey = KeyCode.LEFT;
  static final int _rightKey = KeyCode.RIGHT;
  static final int _dropKey = KeyCode.SPACE;

  final BrowserKeyboardService _browserKeyboardService =
      BrowserKeyboardService();

  @override
  State update(State state) {
    _browserKeyboardService.tick();

    if (_browserKeyboardService.isKeyNewlyPressed(_clockwiseKey)) {
      state = rotateClockwise(state);
    }
    if (_browserKeyboardService.isKeyNewlyPressed(_counterclockwiseKey)) {
      state = rotateCounterclockwise(state);
    }
    if (_browserKeyboardService.isKeyNewlyPressed(_leftKey)) {
      state = moveLeft(state);
    }
    if (_browserKeyboardService.isKeyNewlyPressed(_rightKey)) {
      state = moveRight(state);
    }
    if (_browserKeyboardService.isKeyNewlyPressed(_dropKey)) {
      state = allChains(drop(state));
    }
    return state;
  }
}
