import 'dart:html';

import 'package:puyo/src/core/model/state.dart';
import 'package:puyo/src/shell/runner.dart';
import 'package:puyo/src/shell/system.dart';

class BrowserRunner implements Runner {
  static final _speed = 1000 / 60; // 60 fps

  State _state;
  List<System> _systems;
  num _timeOfLastTick;

  @override
  void run(State initialState, List<System> systems) async {
    _state = initialState;
    _systems = systems;
    _timeOfLastTick = await window.animationFrame;
    _state = _tick(_state, _systems);

    while (true) {
      final num deltaSinceLastTick =
          (await window.animationFrame) - _timeOfLastTick;
      if (deltaSinceLastTick > _speed) {
        _state = _tick(_state, _systems);
      }
    }
  }

  static State _tick(State state, List<System> systems) {
    systems.forEach((system) => state = system.update(state));
    return state;
  }
}
