import 'dart:html';

class BrowserKeyboardService {
  Map<int, bool> _pressed = {};
  Map<int, bool> _truePressed = {};
  Map<int, bool> _pressedThisFrame = {};
  Map<int, bool> _pressedSinceLastFrame = {};

  BrowserKeyboardService() {
    window.onKeyDown.listen((KeyboardEvent e) {
      if (!_pressed.containsKey(e.keyCode) || !_pressed[e.keyCode]) {
        _pressed[e.keyCode] = true;
        _pressedSinceLastFrame[e.keyCode] = true;
      }
    });
    window.onKeyUp.listen((KeyboardEvent e) {
      _pressed[e.keyCode] = false;
      _pressedSinceLastFrame[e.keyCode] = false;
    });
    window.onBlur.listen((Event e) {
      _pressed.clear();
      _pressedSinceLastFrame.clear();
    });
  }

  bool isKeyPressed(int keyCode) =>
      _truePressed.containsKey(keyCode) ? _truePressed[keyCode] : false;

  bool isKeyPressedSinceStartOfLastFrame(int keyCode) =>
      _pressedThisFrame.containsKey(keyCode)
          ? _pressedThisFrame[keyCode]
          : false;

  void tickFrame() {
    _pressedThisFrame = _pressedSinceLastFrame;
    _pressedSinceLastFrame = {};
    _truePressed = _pressed;
  }
}
