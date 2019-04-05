import 'dart:html';
import 'dart:math';

import 'package:puyo/src/core/model/common.dart';
import 'package:puyo/src/core/model/field.dart';
import 'package:puyo/src/core/model/state.dart';

const columnCount = 6;
const rowCount = 12;

const int gridSideLength = 50; // px
const int fieldWidth = columnCount * gridSideLength;
const int fieldHeight = rowCount * gridSideLength;

const int canvasWidth =
    fieldWidth + (2 * gridSideLength); // 2 rows on side for queue
const int canvasHeight =
    fieldHeight + (2 * gridSideLength); // 2 columns on top for preview

main() {
  final CanvasElement canvas = querySelector('#canvas');
  querySelector('body').style.margin = '0';
  canvas
    ..width = canvasWidth
    ..height = canvasHeight
    ..style.backgroundColor = '0';
  final CanvasRenderingContext2D renderer = canvas.context2D;
  renderer.clearRect(0, 0, canvasWidth, canvasHeight);

  State state = initialState;

  _drawState(renderer, state);

  window.onKeyDown.listen((KeyboardEvent e) {
    if (e.keyCode == KeyCode.Z) {
      state = rotateCounterclockwise(state);
    } else if (e.keyCode == KeyCode.X) {
      state = rotateClockwise(state);
    } else if (e.keyCode == KeyCode.LEFT) {
      state = moveLeft(state);
    } else if (e.keyCode == KeyCode.RIGHT) {
      state = moveRight(state);
    } else if (e.keyCode == KeyCode.SPACE) {
      state = allChains(drop(state));
    }
    renderer.clearRect(0, 0, canvasWidth, canvasHeight);
    _drawState(renderer, state);
  });
}

const Map<Color, String> colors = {
  Color.red: '#f00',
  Color.green: '#0f0',
  Color.blue: '#00f',
  Color.yellow: '#ff0',
};

const Map<Color, String> ghostColors = {
  Color.red: '#f88',
  Color.green: '#8f8',
  Color.blue: '#88f',
  Color.yellow: '#ff8',
};

void _drawState(CanvasRenderingContext2D renderer, State state) {
  _drawLines(renderer, state);

  for (int columnIndex = 0; columnIndex < columnCount; columnIndex++) {
    for (int rowIndex = 0; rowIndex < rowCount; rowIndex++) {
      if (state.field.cellsByRowByColumn[columnIndex][rowIndex].value ==
          Value.empty) {
        continue;
      }
      _drawPuyo(
          renderer,
          columnIndex,
          rowIndex,
          colors[colorByValue[
              state.field.cellsByRowByColumn[columnIndex][rowIndex].value]]);
    }
  }
  // current piece
  _drawPuyo(
      renderer,
      state.currentPiece
          .columnIndexes[state.currentPiece.colorProcessingOrder.first],
      rowCount,
      colors[state
          .currentPiece.colors[state.currentPiece.colorProcessingOrder.first]]);
  _drawPuyo(
      renderer,
      state.currentPiece
          .columnIndexes[state.currentPiece.colorProcessingOrder.last],
      state.currentPiece.columnIndexes.first ==
              state.currentPiece.columnIndexes.last
          ? rowCount + 1
          : rowCount,
      colors[state
          .currentPiece.colors[state.currentPiece.colorProcessingOrder.last]]);

  // ghost
  if (state.field.indexOfLowestEmptyRowInColumn(
              state.currentPiece.columnIndexes.first) !=
          -1 &&
      state.field.indexOfLowestEmptyRowInColumn(
              state.currentPiece.columnIndexes.last) !=
          -1 &&
      (state.currentPiece.columnIndexes.first !=
              state.currentPiece.columnIndexes.last ||
          state.field.indexOfLowestEmptyRowInColumn(
                  state.currentPiece.columnIndexes.first) !=
              state.field.rowCount - 1)) {
    _drawPuyo(
        renderer,
        state.currentPiece
            .columnIndexes[state.currentPiece.colorProcessingOrder.first],
        state.field.indexOfLowestEmptyRowInColumn(state.currentPiece
            .columnIndexes[state.currentPiece.colorProcessingOrder.first]),
        ghostColors[state.currentPiece
            .colors[state.currentPiece.colorProcessingOrder.first]]);
    _drawPuyo(
        renderer,
        state.currentPiece
            .columnIndexes[state.currentPiece.colorProcessingOrder.last],
        state.field.indexOfLowestEmptyRowInColumn(state.currentPiece
                .columnIndexes[state.currentPiece.colorProcessingOrder.last]) +
            (state.currentPiece.columnIndexes.first ==
                    state.currentPiece.columnIndexes.last
                ? 1
                : 0),
        ghostColors[state.currentPiece
            .colors[state.currentPiece.colorProcessingOrder.last]]);
  }

  // queue
  _drawPuyo(
      renderer, columnCount, rowCount, colors[state.pieceQueue.next.first]);
  _drawPuyo(
      renderer, columnCount, rowCount + 1, colors[state.pieceQueue.next.last]);
  _drawPuyo(renderer, columnCount + 1, rowCount,
      colors[state.pieceQueue.nextNext.first]);
  _drawPuyo(renderer, columnCount + 1, rowCount + 1,
      colors[state.pieceQueue.nextNext.last]);
}

void _drawPuyo(CanvasRenderingContext2D renderer, int columnIndex, int rowIndex,
    String color) {
  //print('drawing column $columnIndex row $rowIndex color $color');
  renderer
    ..fillStyle = color
    ..beginPath()
    ..arc(
        // center x
        (columnIndex * gridSideLength) + (gridSideLength / 2),
        // center y, convert bottom-left origin to top-left origin
        canvasHeight - (rowIndex * gridSideLength) - (gridSideLength / 2),
        // radius
        gridSideLength / 2,
        // start radians
        0,
        // end radians
        2 * pi)
    ..fill();
}

void _drawLines(CanvasRenderingContext2D renderer, State state) {
  // top border of field
  renderer
    ..strokeStyle = '#fff'
    ..beginPath()
    ..moveTo(0, canvasHeight - (state.field.rowCount * gridSideLength))
    ..lineTo(state.field.columnCount * gridSideLength,
        canvasHeight - (state.field.rowCount * gridSideLength))
    ..stroke();

  // right border of field
  renderer
    ..strokeStyle = '#fff'
    ..beginPath()
    ..moveTo(state.field.columnCount * gridSideLength, 0)
    ..lineTo(state.field.columnCount * gridSideLength, canvasHeight)
    ..stroke();
}
