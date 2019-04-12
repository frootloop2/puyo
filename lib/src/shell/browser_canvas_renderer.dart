import 'dart:html';
import 'dart:math';

import 'package:puyo/src/core/model/common.dart';
import 'package:puyo/src/core/model/field.dart';
import 'package:puyo/src/core/model/state.dart';
import 'package:puyo/src/shell/system.dart';

class BrowserCanvasRenderer implements System {
  static final int _columnCount = 6;
  static final int _rowCount = 12;

  static final int _gridSideLength = 50; // px
  static final int _fieldWidth = _columnCount * _gridSideLength;
  static final int _fieldHeight = _rowCount * _gridSideLength;

  static final int _canvasWidth =
      _fieldWidth + (2 * _gridSideLength); // 2 rows on side for queue
  static final int _canvasHeight =
      _fieldHeight + (2 * _gridSideLength); // 2 columns on top for preview

  static final Map<Color, String> _colors = {
    Color.red: '#f00',
    Color.green: '#0f0',
    Color.blue: '#00f',
    Color.yellow: '#ff0',
  };

  static final Map<Color, String> _ghostColors = {
    Color.red: '#f88',
    Color.green: '#8f8',
    Color.blue: '#88f',
    Color.yellow: '#ff8',
  };

  final CanvasElement _canvas = querySelector('#canvas');

  CanvasRenderingContext2D get _renderer => _canvas.context2D;

  BrowserCanvasRenderer() {
    querySelector('body').style.margin = '0';
    _canvas
      ..width = _canvasWidth
      ..height = _canvasHeight
      ..style.backgroundColor = '0';
  }

  @override
  State update(State state) {
    _renderer.clearRect(0, 0, _canvasWidth, _canvasHeight);
    _drawState(_renderer, state);
    return state;
  }

  static void _drawState(CanvasRenderingContext2D renderer, State state) {
    _drawLines(renderer, state);

    for (int columnIndex = 0; columnIndex < _columnCount; columnIndex++) {
      for (int rowIndex = 0; rowIndex < _rowCount; rowIndex++) {
        if (state.field.cellsByRowByColumn[columnIndex][rowIndex].isEmpty) {
          continue;
        }
        _drawPuyo(
            renderer,
            columnIndex,
            rowIndex,
            _colors[colorByValue[
                state.field.cellsByRowByColumn[columnIndex][rowIndex].value]]);
      }
    }
    // current piece
    _drawPuyo(
        renderer,
        state.currentPiece
            .columnIndexes[state.currentPiece.colorProcessingOrder.first],
        _rowCount,
        _colors[state.currentPiece
            .colors[state.currentPiece.colorProcessingOrder.first]]);
    _drawPuyo(
        renderer,
        state.currentPiece
            .columnIndexes[state.currentPiece.colorProcessingOrder.last],
        state.currentPiece.columnIndexes.first ==
                state.currentPiece.columnIndexes.last
            ? _rowCount + 1
            : _rowCount,
        _colors[state.currentPiece
            .colors[state.currentPiece.colorProcessingOrder.last]]);

    // ghost
    if (!isColumnFull(state.field, state.currentPiece.columnIndexes.first) &&
        !isColumnFull(state.field, state.currentPiece.columnIndexes.last) &&
        (state.currentPiece.columnIndexes.first !=
                state.currentPiece.columnIndexes.last ||
            indexOfLowestEmptyRowInColumn(
                    state.field, state.currentPiece.columnIndexes.first) !=
                state.field.rowCount - 1)) {
      _drawPuyo(
          renderer,
          state.currentPiece
              .columnIndexes[state.currentPiece.colorProcessingOrder.first],
          indexOfLowestEmptyRowInColumn(
              state.field,
              state.currentPiece.columnIndexes[
                  state.currentPiece.colorProcessingOrder.first]),
          _ghostColors[state.currentPiece
              .colors[state.currentPiece.colorProcessingOrder.first]]);
      _drawPuyo(
          renderer,
          state.currentPiece
              .columnIndexes[state.currentPiece.colorProcessingOrder.last],
          indexOfLowestEmptyRowInColumn(
                  state.field,
                  state.currentPiece.columnIndexes[
                      state.currentPiece.colorProcessingOrder.last]) +
              (state.currentPiece.columnIndexes.first ==
                      state.currentPiece.columnIndexes.last
                  ? 1
                  : 0),
          _ghostColors[state.currentPiece
              .colors[state.currentPiece.colorProcessingOrder.last]]);
    }

    // queue
    _drawPuyo(renderer, _columnCount, _rowCount,
        _colors[state.pieceQueue.next.first]);
    _drawPuyo(renderer, _columnCount, _rowCount + 1,
        _colors[state.pieceQueue.next.last]);
    _drawPuyo(renderer, _columnCount + 1, _rowCount,
        _colors[state.pieceQueue.nextNext.first]);
    _drawPuyo(renderer, _columnCount + 1, _rowCount + 1,
        _colors[state.pieceQueue.nextNext.last]);
  }

  static void _drawPuyo(CanvasRenderingContext2D renderer, int columnIndex,
      int rowIndex, String color) {
    //print('drawing column $columnIndex row $rowIndex color $color');
    renderer
      ..fillStyle = color
      ..beginPath()
      ..arc(
          // center x
          (columnIndex * _gridSideLength) + (_gridSideLength / 2),
          // center y, convert bottom-left origin to top-left origin
          _canvasHeight - (rowIndex * _gridSideLength) - (_gridSideLength / 2),
          // radius
          _gridSideLength / 2,
          // start radians
          0,
          // end radians
          2 * pi)
      ..fill();
  }

  static void _drawLines(CanvasRenderingContext2D renderer, State state) {
    // top border of field
    renderer
      ..strokeStyle = '#fff'
      ..beginPath()
      ..moveTo(0, _canvasHeight - (state.field.rowCount * _gridSideLength))
      ..lineTo(state.field.columnCount * _gridSideLength,
          _canvasHeight - (state.field.rowCount * _gridSideLength))
      ..stroke();

    // right border of field
    renderer
      ..strokeStyle = '#fff'
      ..beginPath()
      ..moveTo(state.field.columnCount * _gridSideLength, 0)
      ..lineTo(state.field.columnCount * _gridSideLength, _canvasHeight)
      ..stroke();
  }
}
