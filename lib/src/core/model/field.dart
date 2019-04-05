import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:puyo/src/core/chain.dart';
import 'package:puyo/src/core/model/common.dart';
import 'package:puyo/src/core/model/piece.dart';

part 'field.g.dart';

enum Value { empty, red, green, blue, yellow }

const Map<Value, String> characterByValue = {
  Value.empty: 'E',
  Value.red: 'R',
  Value.green: 'G',
  Value.blue: 'B',
  Value.yellow: 'Y',
};

const Map<Color, Value> valueByColor = {
  Color.red: Value.red,
  Color.green: Value.green,
  Color.blue: Value.blue,
  Color.yellow: Value.yellow,
};

const Map<Value, Color> colorByValue = {
  Value.red: Color.red,
  Value.green: Color.green,
  Value.blue: Color.blue,
  Value.yellow: Color.yellow,
};

abstract class Cell implements Built<Cell, CellBuilder> {
  Value get value;

  int get columnIndex;

  int get rowIndex;

  bool get isEmpty => value == Value.empty;

  bool get isNotEmpty => !isEmpty;

  Cell._();

  factory Cell([updates(CellBuilder b)]) = _$Cell;
}

abstract class Field implements Built<Field, FieldBuilder> {
  BuiltList<BuiltList<Cell>> get cellsByRowByColumn;

  BuiltSet<Cell> get cells =>
      BuiltSet(cellsByRowByColumn.expand((column) => column));

  int get columnCount => cellsByRowByColumn.length;

  int get rowCount => cellsByRowByColumn.first.length;

  int indexOfLowestEmptyRowInColumn(int columnIndex) =>
      cellsByRowByColumn[columnIndex]
          .indexWhere((cell) => cell.value == Value.empty);

  Field._();

  factory Field([updates(FieldBuilder b)]) = _$Field;
}

BuiltSet<Cell> neighbors(Field field, Cell cell) {
  SetBuilder<Cell> builder = SetBuilder();
  if (cell.columnIndex > 0) {
    builder.add(field.cellsByRowByColumn[cell.columnIndex - 1][cell.rowIndex]);
  }
  if (cell.columnIndex < 5) {
    builder.add(field.cellsByRowByColumn[cell.columnIndex + 1][cell.rowIndex]);
  }
  if (cell.rowIndex > 0) {
    builder.add(field.cellsByRowByColumn[cell.columnIndex][cell.rowIndex - 1]);
  }
  if (cell.rowIndex < 11) {
    builder.add(field.cellsByRowByColumn[cell.columnIndex][cell.rowIndex + 1]);
  }
  return builder.build();
}

final Field emptyField =
    Field((b) => b.cellsByRowByColumn = ListBuilder(List.generate(
        6,
        (columnIndex) => BuiltList<Cell>(List<Cell>.generate(
            12,
            (rowIndex) => Cell((b) => b
              ..value = Value.empty
              ..columnIndex = columnIndex
              ..rowIndex = rowIndex))))));

void printField(Field field) {
  for (int rowIndex = field.rowCount - 1; rowIndex >= 0; rowIndex--) {
    print(field.cellsByRowByColumn
        .map((column) => characterByValue[column[rowIndex].value])
        .join());
  }
}

// returns original field if can't be dropped because column is full
Field dropPiece(Field field, final Piece piece) {
  if (piece.columnIndexes.any((columnIndex) =>
      field.indexOfLowestEmptyRowInColumn(columnIndex) == -1)) {
    return field;
  }
  if (piece.columnIndexes.first == piece.columnIndexes.last &&
      field.indexOfLowestEmptyRowInColumn(piece.columnIndexes.first) ==
          field.rowCount - 1) {
    return field;
  }
  piece.colorProcessingOrder.forEach((colorIndex) {
    final Color color = piece.colors[colorIndex];
    final int columnIndex = piece.columnIndexes[colorIndex];
    final int rowIndex = field.indexOfLowestEmptyRowInColumn(columnIndex);
    field = field.rebuild((b) => b.cellsByRowByColumn[columnIndex] =
        b.cellsByRowByColumn[columnIndex].rebuild((b) => b[rowIndex] =
            b[rowIndex].rebuild((b) => b.value = valueByColor[color])));
  });
  return field;
}

Field removeChains(Field field) {
  final ListBuilder<BuiltList<Cell>> newCells =
      field.cellsByRowByColumn.toBuilder();
  final BuiltSet<Cell> poppedCells = chainsInField(field);
  poppedCells.forEach((poppedCell) => newCells[poppedCell.columnIndex] =
      newCells[poppedCell.columnIndex].rebuild((b) => b[poppedCell.rowIndex] =
          b[poppedCell.rowIndex].rebuild((b) => b.value = Value.empty)));
  return field.rebuild((b) => b.cellsByRowByColumn = newCells);
}

Field fall(Field field) {
  final ListBuilder<BuiltList<Cell>> newCells =
      field.cellsByRowByColumn.toBuilder();
  for (int columnIndex = 0; columnIndex < field.columnCount; columnIndex++) {
    int lowestEmptyRowInColumn =
        field.indexOfLowestEmptyRowInColumn(columnIndex);
    if (lowestEmptyRowInColumn == -1) {
      continue;
    }
    for (int rowIndex = lowestEmptyRowInColumn + 1;
        rowIndex < field.rowCount;
        rowIndex++) {
      final Value value = field.cellsByRowByColumn[columnIndex][rowIndex].value;
      if (value == Value.empty) {
        continue;
      }

      // set destination
      newCells[columnIndex] = newCells[columnIndex].rebuild((b) =>
          b[lowestEmptyRowInColumn] =
              b[lowestEmptyRowInColumn].rebuild((b) => b.value = value));
      // clear origin
      newCells[columnIndex] = newCells[columnIndex].rebuild((b) =>
          b[rowIndex] = b[rowIndex].rebuild((b) => b.value = Value.empty));

      lowestEmptyRowInColumn++;
    }
  }
  return field.rebuild((b) => b.cellsByRowByColumn = newCells);
}
