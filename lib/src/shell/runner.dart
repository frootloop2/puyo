import 'package:puyo/src/core/model/state.dart';
import 'package:puyo/src/shell/system.dart';

abstract class Runner {
  void run(State initialState, List<System> systems);
}
