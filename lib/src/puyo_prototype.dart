import 'dart:collection';
import 'dart:math';

const int rowCount = 12;
const int columnCount = 6;
const int minimumChainLength = 4;

class State {
  final Random _random = new Random();

  /// data

  // field value by row by column. (0,0) is the bottom left of the field.
  // Ex: field[0][1] is column 0 row 1.
  final List<List<FieldCell>> _field;
  final Queue<Piece> _nextPieceQueue;

  Piece _currentPiece;

  Set<FieldCell> get _allFieldCells =>
      _field.expand((column) => column).toSet();

  State()
      : _field = List.generate(
            columnCount,
            (columnIndex) => List.generate(
                rowCount, (rowIndex) => FieldCell()..value = FieldValue.empty)),
        _nextPieceQueue = Queue() {
    for (int columnIndex = 0; columnIndex < columnCount; columnIndex++) {
      for (int rowIndex = 0; rowIndex < rowCount; rowIndex++) {
        final FieldCell cell = _field[columnIndex][rowIndex];
        cell.neighbors = {};
        if (columnIndex > 0) {
          cell.neighbors.add(_field[columnIndex - 1][rowIndex]);
        }
        if (columnIndex < columnCount - 1) {
          cell.neighbors.add(_field[columnIndex + 1][rowIndex]);
        }
        if (rowIndex > 0) {
          cell.neighbors.add(_field[columnIndex][rowIndex - 1]);
        }
        if (rowIndex < rowCount - 1) {
          cell.neighbors.add(_field[columnIndex][rowIndex + 1]);
        }
      }
    }
    _nextPieceQueue.addAll([_newPiece(), _newPiece()]);
    _spawnPiece();
  }

  /// controls

  void onMoveLeft() {
    _currentPiece.moveLeft();
  }

  void onMoveRight() {
    _currentPiece.moveRight();
  }

  void onRotateClockwise() {
    _currentPiece.rotateClockwise();
  }

  void onRotateCounterClockwise() {
    _currentPiece.rotateCounterClockwise();
  }

  void onDrop() {
    _currentPiece.colorProcessingOrder.forEach(_placePuyo);
    _resolveField();
    _spawnPiece();
  }

  void _placePuyo(int colorIndex) {
    final Color color = _currentPiece.colors[colorIndex];
    final FieldValue fieldValue = fieldValueByColor[color];
    final int colorDestinationColumn =
        _currentPiece.colorColumnIndexes[colorIndex];
    final int colorDestinationRow = _indexOfLowestEmptyRowInColumn(
        _currentPiece.colorColumnIndexes[colorIndex]);

    _field[colorDestinationColumn][colorDestinationRow].value = fieldValue;
  }

  void _spawnPiece() {
    _currentPiece = _nextPieceQueue.removeFirst();
    _nextPieceQueue.add(_newPiece());
  }

  Piece _newPiece() {
    return Piece([
      Color.values[_random.nextInt(Color.values.length)],
      Color.values[_random.nextInt(Color.values.length)]
    ]);
  }

  int _indexOfLowestEmptyRowInColumn(int columnIndex) {
    return _field[columnIndex]
        .indexWhere((fieldCell) => fieldCell.value == FieldValue.empty);
  }

  /// mechanics

  void _resolveField() {
    final Set<FieldCell> poppedPuyos = _allFieldCells
        .where((fieldCell) => fieldCell.value != FieldValue.empty)
        .expand(_findPoppedChain)
        .toSet(); // de-duplicates

    if (poppedPuyos.isEmpty) {
      return;
    }

    // pop
    poppedPuyos.forEach((fieldCell) => fieldCell.value = FieldValue.empty);

    // gravity
    for (int columnIndex = 0; columnIndex < columnCount; columnIndex++) {
      for (int rowIndex = 0; rowIndex < rowCount; rowIndex++) {
        final FieldCell cell = _field[columnIndex][rowIndex];
        if (cell.value == FieldValue.empty) {
          continue;
        }
        if (rowIndex > _indexOfLowestEmptyRowInColumn(columnIndex)) {
          final FieldCell destinationCell =
              _field[columnIndex][_indexOfLowestEmptyRowInColumn(columnIndex)];
          destinationCell.value = cell.value;
          cell.value = FieldValue.empty;
        }
      }
    }

    // chain
    _resolveField();
  }

  Set<FieldCell> _findPoppedChain(FieldCell fieldCell) {
    final Set<FieldCell> chain = _findChain(fieldCell);
    return chain.length >= minimumChainLength ? chain : {};
  }

  Set<FieldCell> _findChain(FieldCell fieldCell) {
    return _findChainRecurse(fieldCell, {});
  }

  Set<FieldCell> _findChainRecurse(
      FieldCell fieldCell, Set<FieldCell> visitedCells) {
    visitedCells.add(fieldCell);
    return fieldCell.neighborsWithSameValue
        .where((neighbor) => !visitedCells.contains(neighbor))
        .expand((neighbor) => _findChainRecurse(neighbor, visitedCells))
        .toSet()
          ..add(fieldCell);
  }

  /// display
  List<List<FieldValue>> get field => _field
      .map((columnCells) =>
          columnCells.map((fieldCell) => fieldCell.value).toList())
      .toList();

  Piece get currentPiece => _currentPiece;

  void printField() {
    for (int rowIndex = rowCount - 1; rowIndex >= 0; rowIndex--) {
      print(_field
          .map((column) => characterByFieldValue[column[rowIndex].value])
          .join());
    }
  }
}

enum FieldValue {
  empty,
  red,
  green,
  blue,
  yellow,
}
enum Color {
  red,
  green,
  blue,
  yellow,
}

const Map<FieldValue, Color> colorByFieldValue = {
  FieldValue.red: Color.red,
  FieldValue.green: Color.green,
  FieldValue.blue: Color.blue,
  FieldValue.yellow: Color.yellow,
};

const Map<Color, FieldValue> fieldValueByColor = {
  Color.red: FieldValue.red,
  Color.green: FieldValue.green,
  Color.blue: FieldValue.blue,
  Color.yellow: FieldValue.yellow,
};

const Map<FieldValue, String> characterByFieldValue = {
  FieldValue.empty: 'E',
  FieldValue.red: 'R',
  FieldValue.green: 'G',
  FieldValue.blue: 'B',
  FieldValue.yellow: 'Y',
};

// direction from color1 to color2
enum PieceOrientation {
  up,
  left,
  down,
  right,
}

const List<PieceOrientation> clockwiseRotationOrder = [
  PieceOrientation.up,
  PieceOrientation.right,
  PieceOrientation.down,
  PieceOrientation.left,
];

class FieldCell {
  FieldValue value;
  Set<FieldCell> neighbors;

  Iterable<FieldCell> get neighborsWithSameValue =>
      neighbors.where((neighbor) => neighbor.value == value);
}

class Piece {
  final List<Color> colors;
  PieceOrientation _orientation = PieceOrientation.up;
  int _color1ColumnIndex = 0;

  List<int> get colorColumnIndexes {
    return [_color1ColumnIndex, _color2ColumnIndex];
  }

  List<int> get colorProcessingOrder =>
      _orientation == PieceOrientation.down ? [1, 0] : [0, 1];

  int get _color2ColumnIndex {
    int offsetFromColor1ColumnIndex;
    switch (_orientation) {
      case PieceOrientation.up:
      case PieceOrientation.down:
        offsetFromColor1ColumnIndex = 0;
        break;
      case PieceOrientation.right:
        offsetFromColor1ColumnIndex = 1;
        break;
      case PieceOrientation.left:
        offsetFromColor1ColumnIndex = -1;
    }
    return _color1ColumnIndex + offsetFromColor1ColumnIndex;
  }

  Piece(this.colors);

  void moveLeft() {
    _color1ColumnIndex = max(
        _orientation == PieceOrientation.left ? 1 : 0, _color1ColumnIndex - 1);
  }

  void moveRight() {
    _color1ColumnIndex = min(
        _orientation == PieceOrientation.right
            ? columnCount - 2
            : columnCount - 1,
        _color1ColumnIndex + 1);
  }

  void rotateClockwise() {
    if (_orientation == clockwiseRotationOrder.last) {
      _orientation = clockwiseRotationOrder.first;
    } else {
      _orientation = clockwiseRotationOrder[
          clockwiseRotationOrder.indexOf(_orientation) + 1];
    }

    // wall kick
    if (_orientation == PieceOrientation.left) {
      _color1ColumnIndex = max(1, _color1ColumnIndex);
    }

    if (_orientation == PieceOrientation.right) {
      _color1ColumnIndex = min(columnCount - 2, _color1ColumnIndex);
    }
  }

  void rotateCounterClockwise() {
    if (_orientation == clockwiseRotationOrder.first) {
      _orientation = clockwiseRotationOrder.last;
    } else {
      _orientation = clockwiseRotationOrder[
          clockwiseRotationOrder.indexOf(_orientation) - 1];
    }

    // wall kick
    if (_orientation == PieceOrientation.left) {
      _color1ColumnIndex = max(1, _color1ColumnIndex);
    }

    if (_orientation == PieceOrientation.right) {
      _color1ColumnIndex = min(columnCount - 2, _color1ColumnIndex);
    }
  }
}
