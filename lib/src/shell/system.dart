import 'package:puyo/src/core/model/state.dart';

abstract class System {
  State update(State state);
}
