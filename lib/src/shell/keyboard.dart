import 'dart:html';

import 'package:puyo/src/core/model/input.dart';

class Keyboard {
  static final Map<int, Input> _inputByKeyCode = {
    KeyCode.LEFT: Input.moveLeft,
    KeyCode.RIGHT: Input.moveRight,
    KeyCode.X: Input.rotateClockwise,
    KeyCode.Z: Input.rotateCounterclockwise,
    KeyCode.SPACE: Input.drop
  };

  final Set<Input> _inputsPressedForThisTick = {};
  final Set<Input> _inputsPressedAfterCurrentTick = {};

  Keyboard() {
    window.onKeyDown.listen((KeyboardEvent e) {
      _inputsPressedAfterCurrentTick.add(_inputByKeyCode[e.keyCode]);
    });
  }

  bool isInputNewlyPressed(Input input) =>
      _inputsPressedForThisTick.contains(input);

  void tick() {
    _inputsPressedForThisTick
      ..clear()
      ..addAll(_inputsPressedAfterCurrentTick);
    _inputsPressedAfterCurrentTick.clear();
  }
}
