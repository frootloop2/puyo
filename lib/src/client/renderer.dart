import 'dart:html';
import 'dart:math';

import 'package:puyo/src/core/model/color.dart';
import 'package:puyo/src/core/model/field.dart';
import 'package:puyo/src/core/model/piece.dart';
import 'package:puyo/src/core/model/piece_queue.dart';
import 'package:puyo/src/core/model/state.dart';

class Renderer {
  static final Map<Value, String> _hexByValue = {
    Value.empty: '#000',
    Value.trash: '#fff',
    Value.red: _hexByColor[Color.red],
    Value.green: _hexByColor[Color.green],
    Value.blue: _hexByColor[Color.blue],
    Value.yellow: _hexByColor[Color.yellow],
  };
  static final Map<Color, String> _hexByColor = {
    Color.red: '#f00',
    Color.green: '#0f0',
    Color.blue: '#00f',
    Color.yellow: '#ff0',
  };
  static final Map<Color, String> _ghostHexByColor = {
    Color.red: '#f88',
    Color.green: '#8f8',
    Color.blue: '#88f',
    Color.yellow: '#ff8',
  };
  static final int _gridSideLength = 50; // px

  int _fieldWidth;
  int _fieldHeight;
  int _canvasWidth;
  int _canvasHeight;

  final CanvasElement _canvas;

  CanvasRenderingContext2D get _renderer => _canvas.context2D;

  Renderer(String canvasId, int columnCount, int rowCount)
      : _canvas = querySelector('#$canvasId'),
        _fieldWidth = columnCount * _gridSideLength,
        _fieldHeight = rowCount * _gridSideLength,
        // 2 extra rows on the side for queue
        _canvasWidth = columnCount * _gridSideLength + (2 * _gridSideLength),
        // 2 extra columns on top for preview
        _canvasHeight = rowCount * _gridSideLength + (2 * _gridSideLength) {
    querySelector('body').style.margin = '0';
    _canvas
      ..width = _canvasWidth
      ..height = _canvasHeight
      ..style.backgroundColor = '0';
    _renderer.font = "16px monospace";
  }

  State render(State state) {
    _clearCanvas();
    _drawLines(state);
    _drawField(state.field);
    _drawCurrentPieceGhost(state.field, state.currentPiece);
    _drawCurrentPiece(state.currentPiece);
    _drawPieceQueue(
        state.pieceQueue, state.field.columnCount, state.field.rowCount);
    _drawPendingTrash(state.pendingTrash);
    return state;
  }

  void _clearCanvas() => _renderer.clearRect(0, 0, _canvasWidth, _canvasHeight);

  void _drawLines(State state) {
    // top border of field
    _renderer
      ..strokeStyle = '#fff'
      ..beginPath()
      ..moveTo(0, _canvasHeight - _fieldHeight)
      ..lineTo(_fieldWidth, _canvasHeight - _fieldHeight)
      ..stroke();

    // right border of field
    _renderer
      ..strokeStyle = '#fff'
      ..beginPath()
      ..moveTo(state.field.columnCount * _gridSideLength, 0)
      ..lineTo(state.field.columnCount * _gridSideLength, _canvasHeight)
      ..stroke();
  }

  void _drawField(Field field) =>
      field.cells.where((cell) => cell.isNotEmpty).forEach((cell) =>
          _drawPuyo(cell.columnIndex, cell.rowIndex, _hexByValue[cell.value]));

  void _drawCurrentPiece(Piece piece) {
    _drawPuyo(
        piece.columnIndexes[piece.colorProcessingOrder.first],
        piece.rowIndexes[piece.colorProcessingOrder.first],
        _hexByColor[piece.colors[piece.colorProcessingOrder.first]]);
    _drawPuyo(
        piece.columnIndexes[piece.colorProcessingOrder.last],
        piece.rowIndexes[piece.colorProcessingOrder.last],
        _hexByColor[piece.colors[piece.colorProcessingOrder.last]]);
  }

  void _drawCurrentPieceGhost(Field field, Piece piece) {
    bool eitherColumnFull = isColumnFull(field, piece.columnIndexes.first) ||
        isColumnFull(field, piece.columnIndexes.last);
    bool bothPuyosInSameColumn =
        piece.columnIndexes.first == piece.columnIndexes.last;
    bool singleColumnHasOnly1EmptyCell =
        indexOfLowestEmptyRowInColumn(field, piece.columnIndexes.first) ==
            field.rowCount - 1;

    // skip drawing ghost if piece is not able to be dropped
    if (eitherColumnFull ||
        (bothPuyosInSameColumn && singleColumnHasOnly1EmptyCell)) {
      return;
    }

    _drawPuyo(
        piece.columnIndexes[piece.colorProcessingOrder.first],
        indexOfLowestEmptyRowInColumn(
            field, piece.columnIndexes[piece.colorProcessingOrder.first]),
        _ghostHexByColor[piece.colors[piece.colorProcessingOrder.first]]);
    // draw above first ghost puyo if they are in the same column
    _drawPuyo(
        piece.columnIndexes[piece.colorProcessingOrder.last],
        indexOfLowestEmptyRowInColumn(
                field, piece.columnIndexes[piece.colorProcessingOrder.last]) +
            (bothPuyosInSameColumn ? 1 : 0),
        _ghostHexByColor[piece.colors[piece.colorProcessingOrder.last]]);
  }

  void _drawPieceQueue(PieceQueue pieceQueue, int columnCount, int rowCount) {
    // next
    _drawPuyo(columnCount, rowCount - 2, _hexByColor[pieceQueue.next.first]);
    _drawPuyo(columnCount, rowCount - 1, _hexByColor[pieceQueue.next.last]);
    // next next
    _drawPuyo(
        columnCount + 1, rowCount - 2, _hexByColor[pieceQueue.nextNext.first]);
    _drawPuyo(
        columnCount + 1, rowCount - 1, _hexByColor[pieceQueue.nextNext.last]);
  }

  void _drawPendingTrash(int trashAmount) {
    _renderer
      ..fillStyle = '#fff'
      ..fillText('Trash: $trashAmount', _fieldWidth,
          _canvasHeight - (_fieldHeight - 32));
  }

  void _drawPuyo(int columnIndex, int rowIndex, String color) => _renderer
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
