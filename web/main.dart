import 'package:puyo/src/core/model/state.dart';
import 'package:puyo/src/shell/browser_canvas_renderer.dart';
import 'package:puyo/src/shell/browser_keyboard_processor.dart';
import 'package:puyo/src/shell/browser_runner.dart';

main() {
  BrowserRunner()
      .run(initialState, [BrowserKeyboardProcessor(), BrowserCanvasRenderer()]);
}
