import 'package:puyo/src/core/model/input.dart';
import 'package:puyo/src/core/model/state.dart';
import 'package:puyo/src/shell/keyboard.dart';

State update(State state, Keyboard keyboard) {
  if (keyboard.isInputNewlyPressed(Input.moveLeft)) {
    state = moveLeft(state);
  }
  if (keyboard.isInputNewlyPressed(Input.moveRight)) {
    state = moveRight(state);
  }
  if (keyboard.isInputNewlyPressed(Input.rotateClockwise)) {
    state = rotateClockwise(state);
  }
  if (keyboard.isInputNewlyPressed(Input.rotateCounterclockwise)) {
    state = rotateCounterclockwise(state);
  }
  if (keyboard.isInputNewlyPressed(Input.drop)) {
    state = allChains(drop(state));
  }
  return state;
}
