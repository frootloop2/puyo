import 'package:puyo/src/core/model/state.dart';

main(List<String> arguments) {
  State state = initialState;
  state = rotateClockwise(state);
  state = drop(state);
  state = rotateClockwise(state);
  state = drop(state);
  state = rotateClockwise(state);
  state = drop(state);
  state = drop(state);
  state = allChains(state);
  printState(state);
}
