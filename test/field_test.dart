import 'package:built_collection/built_collection.dart';
import 'package:puyo/src/core/model/color.dart';
import 'package:puyo/src/core/model/direction.dart';
import 'package:puyo/src/core/model/field.dart';
import 'package:puyo/src/core/model/piece.dart';
import 'package:test/test.dart';

void main() {
  group('cell', () {
    test('emptiness getters', () {
      final Cell emptyCell = Cell((b) => b
        ..value = Value.empty
        ..columnIndex = 0
        ..rowIndex = 0);
      final Cell redCell = emptyCell.rebuild((b) => b..value = Value.red);

      expect(emptyCell.isEmpty, isTrue);
      expect(emptyCell.isNotEmpty, isFalse);
      expect(redCell.isEmpty, isFalse);
      expect(redCell.isNotEmpty, isTrue);
    });
  });

  group('field', () {
    test('dimension and cells getters', () {
      final Field field = fieldFromString('EEEE\nEEEE');

      expect(field.rowCount, 2);
      expect(field.columnCount, 4);
      expect(field.cells,
          unorderedEquals(field.cellsByRowByColumn.expand((column) => column)));
    });

    group('queries', () {
      final Field field = fieldFromString('GEEE\n'
          'GEEE\n'
          'GEGE\n'
          'GGEE');

      test('lowest empty row in column', () {
        expect(indexOfLowestEmptyRowInColumn(field, 0), -1);
        expect(indexOfLowestEmptyRowInColumn(field, 1), 1);
        expect(indexOfLowestEmptyRowInColumn(field, 2), 0);
        expect(indexOfLowestEmptyRowInColumn(field, 3), 0);
      });

      test('full columns', () {
        expect(isColumnFull(field, 0), isTrue);
        expect(isColumnFull(field, 1), isFalse);
        expect(isColumnFull(field, 2), isFalse);
        expect(isColumnFull(field, 3), isFalse);
      });

      test('drop targets', () {
        expect(dropTarget(field, 0), -1);
        expect(dropTarget(field, 1), 1);
        expect(dropTarget(field, 2), 2);
        expect(dropTarget(field, 3), 0);
      });

      test('neighbors', () {
        final BuiltList<BuiltList<Cell>> cells = field.cellsByRowByColumn;

        // bottom left
        expect(neighbors(field, cells[0][0]),
            unorderedEquals([cells[0][1], cells[1][0]]));
        // top left
        expect(neighbors(field, cells[0][3]),
            unorderedEquals([cells[0][2], cells[1][3]]));
        // top right
        expect(neighbors(field, cells[3][3]),
            unorderedEquals([cells[2][3], cells[3][2]]));
        // bottom right
        expect(neighbors(field, cells[3][0]),
            unorderedEquals([cells[3][1], cells[2][0]]));
        // bottom
        expect(neighbors(field, cells[2][0]),
            unorderedEquals([cells[1][0], cells[2][1], cells[3][0]]));
        // left
        expect(neighbors(field, cells[0][2]),
            unorderedEquals([cells[1][2], cells[0][3], cells[0][1]]));
        // top
        expect(neighbors(field, cells[2][3]),
            unorderedEquals([cells[3][3], cells[2][2], cells[1][3]]));
        // right
        expect(neighbors(field, cells[3][2]),
            unorderedEquals([cells[3][3], cells[3][1], cells[2][2]]));
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
          ..corePuyoColumnIndex = 0
          ..orientation = Direction.right);

        test('adds puyos to columns', () {
          final Field field = fieldFromString('EE\nGE\nGG');
          final Field expectedField = fieldFromString('RE\nGB\nGG');

          expect(dropPiece(field, leftRedBluePiece), expectedField);
        });

        test('drops puyos in processing order', () {
          final Field field = fieldFromString('E\nE');
          final Piece downRedBluePiece =
              leftRedBluePiece.rebuild((b) => b.orientation = Direction.down);
          final Field expectedFieldWithDownPiece = fieldFromString('R\nB');
          final Piece upRedBluePiece =
              leftRedBluePiece.rebuild((b) => b.orientation = Direction.up);
          final Field expectedFieldWithUpPiece = fieldFromString('B\nR');

          expect(
              dropPiece(field, downRedBluePiece), expectedFieldWithDownPiece);
          expect(dropPiece(field, upRedBluePiece), expectedFieldWithUpPiece);
        });

        test('does not add piece when column is full', () {
          final Field field = fieldFromString('GE\nGE');

          expect(dropPiece(field, leftRedBluePiece), field);
        });

        test('adds piece if one puyo is in single-empty column', () {
          final Field field = fieldFromString('EE\nGG');
          final Field expectedField = fieldFromString('RB\nGG');

          expect(dropPiece(field, leftRedBluePiece), expectedField);
        });

        test('does not add piece if both are in single-empty column', () {
          final Field field = fieldFromString('E\nG');
          final Piece upPieceOverSingleEmptyColumn =
              leftRedBluePiece.rebuild((b) => b..orientation = Direction.up);

          expect(dropPiece(field, upPieceOverSingleEmptyColumn), field);
        });
      });

      test('removes chained puyos from field', () {
        final Field field = fieldFromString('GGE\n'
            'GRY\n'
            'GRB\n'
            'ERR');
        // reds and greens pop, leaving yellow and blue left over.
        final Field expectedField = fieldFromString('EEE\n'
            'EEY\n'
            'EEB\n'
            'EEE');

        expect(removeChains(field), expectedField);
      });

      test('moves puyos to bottom when column has multiple empty secions', () {
        final Field field = fieldFromString('G\nE\nG\nE');
        final Field expectedField = fieldFromString('E\nE\nG\nG');

        expect(fall(field), expectedField);
      });
    });

    test('drops trash on field', () {
      final Field field = fieldFromString('EEEE\nEEEE\nEEEE');
      final Field expectedField = fieldFromString('EEEE\nTTTT\nTTTT');

      expect(dropTrash(field, 8), expectedField);
    });

    group('string format conversion', () {
      test('field string', () {
        final String string = 'EEEE\nRGBY\nETTE';

        expect(fieldString(fieldFromString(string)), string);
      });

      test('field from string', () {
        final Field field = fieldFromString('EGEY\nRTBE');
        final Field expectedField =
            Field((b) => b.cellsByRowByColumn = ListBuilder<BuiltList<Cell>>([
                  BuiltList<Cell>([
                    Cell((b) => b
                      ..value = Value.red
                      ..columnIndex = 0
                      ..rowIndex = 0),
                    Cell((b) => b
                      ..value = Value.empty
                      ..columnIndex = 0
                      ..rowIndex = 1)
                  ]),
                  BuiltList<Cell>([
                    Cell((b) => b
                      ..value = Value.trash
                      ..columnIndex = 1
                      ..rowIndex = 0),
                    Cell((b) => b
                      ..value = Value.green
                      ..columnIndex = 1
                      ..rowIndex = 1)
                  ]),
                  BuiltList<Cell>([
                    Cell((b) => b
                      ..value = Value.blue
                      ..columnIndex = 2
                      ..rowIndex = 0),
                    Cell((b) => b
                      ..value = Value.empty
                      ..columnIndex = 2
                      ..rowIndex = 1)
                  ]),
                  BuiltList<Cell>([
                    Cell((b) => b
                      ..value = Value.empty
                      ..columnIndex = 3
                      ..rowIndex = 0),
                    Cell((b) => b
                      ..value = Value.yellow
                      ..columnIndex = 3
                      ..rowIndex = 1)
                  ])
                ]));

        expect(field, expectedField);
      });
    });
  });
}
