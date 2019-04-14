import 'dart:html';

import 'package:puyo/src/core/model/state.dart';
import 'package:puyo/src/shell/keyboard.dart';
import 'package:puyo/src/shell/renderer.dart';
import 'package:puyo/src/shell/update.dart';

class Runner {
  static final int fps = 60;
  static final double _minimumTimeBetweenTicks = 1000 / fps;

  static final Keyboard _keyboard = Keyboard();

  Renderer _renderer;
  State _state;
  num _timeOfLastTick;

  void run(State initialState) async {
    _state = initialState;
    _renderer = Renderer(_state.field.columnCount, _state.field.rowCount);

    _timeOfLastTick = await window.animationFrame;
    _tick();

    while (true) {
      final num currentTime = await window.animationFrame;
      if (currentTime - _timeOfLastTick > _minimumTimeBetweenTicks) {
        _timeOfLastTick = currentTime;
        _tick();
      }
    }
  }

  void _tick() {
    _keyboard.tick();
    _state = update(_state, _keyboard);
    _renderer.render(_state);
  }
}
