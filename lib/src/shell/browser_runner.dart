import 'dart:html';

import 'package:puyo/src/core/model/state.dart';
import 'package:puyo/src/shell/runner.dart';
import 'package:puyo/src/shell/system.dart';

class BrowserRunner implements Runner {
  static final int fps = 60;
  static final double _minimumTimeBetweenTicks = 1000 / fps;

  State _state;
  List<System> _systems;
  num _timeOfLastTick;

  @override
  void run(State initialState, List<System> systems) async {
    _state = initialState;
    _systems = systems;

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

  void _tick() => _systems.forEach((system) => _state = system.update(_state));
}
