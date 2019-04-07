import 'package:built_collection/built_collection.dart';
import 'package:puyo/src/core/model/common.dart';
import 'package:puyo/src/core/model/field.dart';
import 'package:puyo/src/core/model/piece.dart';
import 'package:test/test.dart';

void main() {
  Cell buildCell(Value value, int columnIndex, int rowIndex) => Cell((b) => b
    ..value = value
    ..columnIndex = columnIndex
    ..rowIndex = rowIndex);

  BuiltList<Cell> buildColumn(Value value, int columnIndex, int rowCount) =>
      ListBuilder<Cell>(List.generate(
              rowCount, (rowIndex) => buildCell(value, columnIndex, rowIndex)))
          .build();

  ListBuilder<BuiltList<Cell>> buildCellGrid(
          Value value, int columnCount, int rowCount) =>
      ListBuilder(List.generate(columnCount,
          (columnIndex) => buildColumn(value, columnIndex, rowCount)));

  Field setSingleValue(
          Field field, int columnIndex, int rowIndex, Value value) =>
      field.rebuild((b) => b.cellsByRowByColumn[columnIndex] =
          b.cellsByRowByColumn[columnIndex].rebuild((b) =>
              b[rowIndex] = b[rowIndex].rebuild((b) => b.value = value)));

  Field setColumnValue(Field field, int columnIndex, Value value) =>
      field.rebuild((b) => b.cellsByRowByColumn[columnIndex] =
          buildColumn(value, columnIndex, field.rowCount));

  group('cell', () {
    test('emptiness getters', () {
      final Cell emptyCell = buildCell(Value.empty, 0, 0);
      expect(emptyCell.isEmpty, isTrue);
      expect(emptyCell.isNotEmpty, isFalse);

      final Cell redCell = emptyCell.rebuild((b) => b..value = Value.red);
      expect(redCell.isEmpty, isFalse);
      expect(redCell.isNotEmpty, isTrue);
    });
  });

  group('field', () {
    final int rowCount = 12;
    final int columnCount = 6;
    // 0,0: red
    // 1,1: blue
    // *,3: green
    // *,4: red (except top cell)
    // 11,4: empty
    // rest: empty
    final Field field = setSingleValue(
        setColumnValue(
            setColumnValue(
                setSingleValue(
                    setSingleValue(
                        Field((b) => b.cellsByRowByColumn =
                            buildCellGrid(Value.empty, columnCount, rowCount)),
                        0,
                        0,
                        Value.red),
                    1,
                    1,
                    Value.blue),
                3,
                Value.green),
            4,
            Value.red),
        4,
        11,
        Value.empty);

    test('dimension and cells getters', () {
      expect(field.rowCount, rowCount);
      expect(field.columnCount, columnCount);
      expect(field.cells,
          unorderedEquals(field.cellsByRowByColumn.expand((column) => column)));
    });

    group('queries', () {
      test('lowest empty row in column', () {
        expect(indexOfLowestEmptyRowInColumn(field, 0), 1);
        expect(indexOfLowestEmptyRowInColumn(field, 1), 0);
        expect(indexOfLowestEmptyRowInColumn(field, 2), 0);
        expect(indexOfLowestEmptyRowInColumn(field, 3), -1);
      });

      test('full columns', () {
        expect(isColumnFull(field, 0), isFalse);
        expect(isColumnFull(field, 1), isFalse);
        expect(isColumnFull(field, 2), isFalse);
        expect(isColumnFull(field, 3), isTrue);
      });

      test('drop targets', () {
        expect(dropTarget(field, 0), 1);
        expect(dropTarget(field, 1), 2);
        expect(dropTarget(field, 3), -1);
        expect(dropTarget(field, 4), 11);
      });

      test('neighbors', () {
        final BuiltList<BuiltList<Cell>> cells = field.cellsByRowByColumn;
        // bottom left
        expect(neighbors(field, cells[0][0]),
            unorderedEquals([cells[0][1], cells[1][0]]));
        // top left
        expect(neighbors(field, cells[0][11]),
            unorderedEquals([cells[0][10], cells[1][11]]));
        // top right
        expect(neighbors(field, cells[5][11]),
            unorderedEquals([cells[5][10], cells[4][11]]));
        // bottom right
        expect(neighbors(field, cells[5][0]),
            unorderedEquals([cells[5][1], cells[4][0]]));
        // bottom
        expect(neighbors(field, cells[2][0]),
            unorderedEquals([cells[1][0], cells[2][1], cells[3][0]]));
        // left
        expect(neighbors(field, cells[0][5]),
            unorderedEquals([cells[1][5], cells[0][4], cells[0][6]]));
        // top
        expect(neighbors(field, cells[3][11]),
            unorderedEquals([cells[2][11], cells[4][11], cells[3][10]]));
        // right
        expect(neighbors(field, cells[5][5]),
            unorderedEquals([cells[4][5], cells[5][4], cells[5][6]]));
        // middle
        expect(
            neighbors(field, cells[2][2]),
            unorderedEquals(
                [cells[1][2], cells[2][1], cells[2][3], cells[3][2]]));
      });
    });

    group('actions', () {
      group('drop', () {
        final Piece leftRedBluePiece = Piece((b) => b
          ..corePuyoColor = Color.red
          ..secondaryPuyoColor = Color.blue
          ..corePuyoColumnIndex = 2
          ..orientation = Direction.left);
        test('adds puyos to columns', () {
          final Field expectedField = setSingleValue(
              setSingleValue(field, 1, 2, Value.blue), 2, 0, Value.red);
          expect(dropPiece(field, leftRedBluePiece), expectedField);
        });

        test('respects processing order', () {
          final Piece downRedBluePiece =
              leftRedBluePiece.rebuild((b) => b.orientation = Direction.down);
          final Field expectedFieldWithDownPiece = setSingleValue(
              setSingleValue(field, 2, 0, Value.blue), 2, 1, Value.red);
          expect(
              dropPiece(field, downRedBluePiece), expectedFieldWithDownPiece);

          final Piece upRedBluePiece =
              leftRedBluePiece.rebuild((b) => b.orientation = Direction.up);
          final Field expectedFieldWithUpPiece = setSingleValue(
              setSingleValue(field, 2, 0, Value.red), 2, 1, Value.blue);
          expect(dropPiece(field, upRedBluePiece), expectedFieldWithUpPiece);
        });

        test('does not add piece when column is full', () {
          final Piece pieceOverFullColumn =
              leftRedBluePiece.rebuild((b) => b.corePuyoColumnIndex = 3);
          expect(dropPiece(field, pieceOverFullColumn), field);
        });

        test('does not add piece if both are in single-empty column', () {
          final Piece upPieceOverSingleEmptyColumn =
              leftRedBluePiece.rebuild((b) => b
                ..corePuyoColumnIndex = 4
                ..orientation = Direction.up);
          expect(dropPiece(field, upPieceOverSingleEmptyColumn), field);
        });

        test('adds piece if one puyo is in single-empty column', () {
          final Piece pieceOverSingleEmptyColumn =
              leftRedBluePiece.rebuild((b) => b.corePuyoColumnIndex = 5);
          final Field expectedField = setSingleValue(
              setSingleValue(field, 5, 0, Value.red), 4, 11, Value.blue);
          expect(dropPiece(field, pieceOverSingleEmptyColumn), expectedField);
        });
      });

      test('removes chained puyos from field', () {
        final Field expectedField = setColumnValue(
            setColumnValue(field, 4, Value.empty), 3, Value.empty);
        expect(removeChains(field), expectedField);
      });

      test('moves puyos to bottom when column has multiple empty secions', () {
        final Field expectedField = setSingleValue(
            setSingleValue(field, 1, 1, Value.empty), 1, 0, Value.blue);
        expect(fall(field), expectedField);
      });
    });

    test('field string', () {
      expect(
          fieldString(field),
          'EEEGEE\n'
          'EEEGRE\n'
          'EEEGRE\n'
          'EEEGRE\n'
          'EEEGRE\n'
          'EEEGRE\n'
          'EEEGRE\n'
          'EEEGRE\n'
          'EEEGRE\n'
          'EEEGRE\n'
          'EBEGRE\n'
          'REEGRE');
    });
  });
}
