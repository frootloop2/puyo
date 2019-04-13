import 'dart:html';

class BrowserKeyboardService {
  final Set<int> _keyCodesPressedForThisTick = {};
  final Set<int> _keyCodesPressedAfterCurrentTick = {};

  BrowserKeyboardService() {
    window.onKeyDown.listen((KeyboardEvent e) {
      _keyCodesPressedAfterCurrentTick.add(e.keyCode);
    });
  }

  bool isKeyNewlyPressed(int keyCode) =>
      _keyCodesPressedForThisTick.contains(keyCode);

  void tick() {
    _keyCodesPressedForThisTick
      ..clear()
      ..addAll(_keyCodesPressedAfterCurrentTick);
    _keyCodesPressedAfterCurrentTick.clear();
  }
}
