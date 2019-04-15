import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:puyo/src/core/chain.dart';
import 'package:puyo/src/core/model/color.dart';
import 'package:puyo/src/core/model/piece.dart';

part 'field.g.dart';

class Value extends EnumClass {
  static Serializer<Value> get serializer => _$valueSerializer;

  static const Value empty = _$empty;
  static const Value red = _$red;
  static const Value green = _$green;
  static const Value blue = _$blue;
  static const Value yellow = _$yellow;
  static const Value trash = _$trash;

  const Value._(String name) : super(name);

  static BuiltSet<Value> get values => _$values;

  static Value valueOf(String name) => _$valueOf(name);
}

const Map<Value, String> characterByValue = {
  Value.empty: 'E',
  Value.red: 'R',
  Value.green: 'G',
  Value.blue: 'B',
  Value.yellow: 'Y',
  Value.trash: 'T',
};

const Map<String, Value> valueByCharacter = {
  'E': Value.empty,
  'R': Value.red,
  'G': Value.green,
  'B': Value.blue,
  'Y': Value.yellow,
  'T': Value.trash,
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
  static Serializer<Cell> get serializer => _$cellSerializer;

  Value get value;

  int get columnIndex;

  int get rowIndex;

  bool get isEmpty => value == Value.empty;

  bool get isNotEmpty => !isEmpty;

  Cell._();

  factory Cell([updates(CellBuilder b)]) = _$Cell;
}

abstract class Field implements Built<Field, FieldBuilder> {
  static Serializer<Field> get serializer => _$fieldSerializer;

  BuiltList<BuiltList<Cell>> get cellsByRowByColumn;

  BuiltSet<Cell> get cells =>
      BuiltSet(cellsByRowByColumn.expand((column) => column));

  int get columnCount => cellsByRowByColumn.length;

  int get rowCount => cellsByRowByColumn.first.length;

  Field._();

  factory Field([updates(FieldBuilder b)]) = _$Field;
}

/// -1 if column is full, check isColumnFull first
int indexOfLowestEmptyRowInColumn(Field field, int columnIndex) =>
    field.cellsByRowByColumn[columnIndex].indexWhere((cell) => cell.isEmpty);

bool isColumnFull(Field field, int columnIndex) =>
    indexOfLowestEmptyRowInColumn(field, columnIndex) == -1;

int dropTarget(Field field, int columnIndex) => isColumnFull(field, columnIndex)
    ? -1
    : field.cellsByRowByColumn[columnIndex]
            .lastIndexWhere((cell) => cell.isNotEmpty) +
        1;

BuiltSet<Cell> neighbors(Field field, Cell cell) {
  SetBuilder<Cell> builder = SetBuilder();
  if (cell.columnIndex > 0) {
    builder.add(field.cellsByRowByColumn[cell.columnIndex - 1][cell.rowIndex]);
  }
  if (cell.columnIndex < field.columnCount - 1) {
    builder.add(field.cellsByRowByColumn[cell.columnIndex + 1][cell.rowIndex]);
  }
  if (cell.rowIndex > 0) {
    builder.add(field.cellsByRowByColumn[cell.columnIndex][cell.rowIndex - 1]);
  }
  if (cell.rowIndex < field.rowCount - 1) {
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

// returns original field if can't be dropped because column is full
Field dropPiece(Field field, final Piece piece) {
  if (piece.columnIndexes
      .any((columnIndex) => isColumnFull(field, columnIndex))) {
    return field;
  }
  if (piece.columnIndexes.first == piece.columnIndexes.last &&
      indexOfLowestEmptyRowInColumn(field, piece.columnIndexes.first) ==
          field.rowCount - 1) {
    return field;
  }
  return field.rebuild((b) => piece.colorProcessingOrder.forEach((colorIndex) =>
      _dropValue(b, piece.columnIndexes[colorIndex],
          valueByColor[piece.colors[colorIndex]])));
}

//int countGeneratedTrash(Field field) => poppedCellsInField(field).length;

Field removeChains(Field field) {
  final ListBuilder<BuiltList<Cell>> newCells =
      field.cellsByRowByColumn.toBuilder();
  final BuiltSet<Cell> poppedCells = poppedCellsInField(field);
  poppedCells.forEach((poppedCell) => newCells[poppedCell.columnIndex] =
      newCells[poppedCell.columnIndex].rebuild((b) => b[poppedCell.rowIndex] =
          b[poppedCell.rowIndex].rebuild((b) => b.value = Value.empty)));
  return field.rebuild((b) => b.cellsByRowByColumn = newCells);
}

Field fall(Field field) {
  final ListBuilder<BuiltList<Cell>> newCells =
      field.cellsByRowByColumn.toBuilder();
  for (int columnIndex = 0; columnIndex < field.columnCount; columnIndex++) {
    if (isColumnFull(field, columnIndex)) {
      continue;
    }
    int lowestEmptyRowInColumn =
        indexOfLowestEmptyRowInColumn(field, columnIndex);
    for (int rowIndex = lowestEmptyRowInColumn + 1;
        rowIndex < field.rowCount;
        rowIndex++) {
      if (field.cellsByRowByColumn[columnIndex][rowIndex].isEmpty) {
        continue;
      }
      final Value value = field.cellsByRowByColumn[columnIndex][rowIndex].value;

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

Field dropTrash(Field field, int trashAmount) {
  while (trashAmount >= field.columnCount) {
    field = _dropTrashRow(field);
    trashAmount -= field.columnCount;
  }
  field = _dropTrashPartialRow(field, trashAmount);
  return field;
}

// top to bottom, left to right
String fieldString(Field field) {
  String s = '';
  for (int rowIndex = field.rowCount - 1; rowIndex >= 0; rowIndex--) {
    s = s +
        field.cellsByRowByColumn
            .map((column) => characterByValue[column[rowIndex].value])
            .join() +
        (rowIndex == 0 ? '' : '\n');
  }
  return s;
}

Field fieldFromString(String fieldString) {
  List<List<Value>> valuesByColumnByRow = fieldString
      // split string into rows
      .split('\n')
      // fieldString format has top row first for print purposes, but we want
      // top row last for index purposes so we need to reverse it.
      .reversed
      .map((rowString) => rowString
          // split row into cells
          .split('')
          // convert cell string into Value
          .map((valueString) => valueByCharacter[valueString])
          .toList())
      .toList();
  int rowCount = valuesByColumnByRow.length;
  int columnCount = rowCount == 0 ? 0 : valuesByColumnByRow.first.length;

  // TODO (ensure each row is the same length).

  return Field((b) => b.cellsByRowByColumn = ListBuilder(List.generate(
      columnCount,
      (columnIndex) => BuiltList<Cell>(List<Cell>.generate(
          rowCount,
          (rowIndex) => Cell((b) => b
            ..value = valuesByColumnByRow[rowIndex][columnIndex]
            ..columnIndex = columnIndex
            ..rowIndex = rowIndex))))));
}

Field _dropTrashRow(Field field) => field.rebuild((b) {
      for (int columnIndex = 0;
          columnIndex < field.columnCount;
          columnIndex++) {
        if (!isColumnFull(field, columnIndex)) {
          _dropValue(b, columnIndex, Value.trash);
        }
      }
    });

Field _dropTrashPartialRow(Field field, int trashAmount) => field.rebuild((b) {
      final List<int> availableColumns =
          List.generate(field.columnCount, (i) => i)
              .where((columnIndex) => !isColumnFull(field, columnIndex))
              .toList();

      while (trashAmount > 0 && availableColumns.isNotEmpty) {
        // TODO: rethink randomness
        final int columnIndex = availableColumns
            .removeAt(Random().nextInt(availableColumns.length));
        _dropValue(b, columnIndex, Value.trash);
        trashAmount--;
      }
    });

void _dropValue(FieldBuilder fieldBuilder, int columnIndex, Value value) {
  final int rowIndex = dropTarget(fieldBuilder.build(), columnIndex);
  fieldBuilder.cellsByRowByColumn[columnIndex] =
      fieldBuilder.cellsByRowByColumn[columnIndex].rebuild(
          (b) => b[rowIndex] = b[rowIndex].rebuild((b) => b.value = value));
}
