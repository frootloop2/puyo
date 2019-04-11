import 'package:built_collection/built_collection.dart';
import 'package:puyo/src/core/model/common.dart';
import 'package:puyo/src/core/model/piece.dart';
import 'package:test/test.dart';

void main() {
  test('new piece is pointed up in column 2', () {
    final BuiltList<Color> colors = BuiltList([Color.red, Color.green]);
    final expectedPiece = pieceFromString('RG2U');

    expect(newPiece(colors), expectedPiece);
  });

  test('has getters', () {
    final Piece piece = pieceFromString('RG0R');

    expect(piece.colors, BuiltList<Color>([Color.red, Color.green]));
    expect(piece.secondaryPuyoColumnIndex, 1);
    expect(piece.columnIndexes, orderedEquals([0, 1]));
    expect(piece.colorProcessingOrder, orderedEquals([0, 1]));
  });

  test('processing order depends on direction', () {
    expect(pieceFromString('RG0U').colorProcessingOrder, orderedEquals([0, 1]));
    expect(pieceFromString('RG0D').colorProcessingOrder, orderedEquals([1, 0]));
    // Order does not matter for left or right orientations since the puyos
    // will not stack.
  });

  group('moves right', () {
    test('changes columns when there is room', () {
      final Piece piece = pieceFromString('RG0R');
      final Piece expectedPiece = pieceFromString('RG1R');

      expect(movePieceRight(piece, 3), expectedPiece);
    });

    test('wallkicks when moved off the field', () {
      final upPiece = pieceFromString('RG2U');
      final rightPiece = pieceFromString('RG2R');
      final downPiece = pieceFromString('RG2D');
      final leftPiece = pieceFromString('RG3L');

      expect(movePieceRight(upPiece, 3), upPiece);
      expect(movePieceRight(rightPiece, 4), rightPiece);
      expect(movePieceRight(downPiece, 3), downPiece);
      expect(movePieceRight(leftPiece, 4), leftPiece);
    });
  });

  group('move left', () {
    test('changes columns when there is room', () {
      final Piece piece = pieceFromString('RG1R');
      final Piece expectedPiece = pieceFromString('RG0R');

      expect(movePieceLeft(piece), expectedPiece);
    });

    test('wallkicks when moved off the field', () {
      final upPiece = pieceFromString('RG0U');
      final rightPiece = pieceFromString('RG0R');
      final downPiece = pieceFromString('RG0D');
      final leftPiece = pieceFromString('RG1L');

      expect(movePieceLeft(upPiece), upPiece);
      expect(movePieceLeft(rightPiece), rightPiece);
      expect(movePieceLeft(downPiece), downPiece);
      expect(movePieceLeft(leftPiece), leftPiece);
    });
  });

  group('rotate clockwise', () {
    test('rotates around core puyo when there is room', () {
      final Piece upPiece = pieceFromString('RG2U');
      final Piece rightPiece = pieceFromString('RG2R');
      final Piece downPiece = pieceFromString('RG2D');
      final Piece leftPiece = pieceFromString('RG2L');

      expect(rotatePieceClockwise(upPiece, 4), rightPiece);
      expect(rotatePieceClockwise(rightPiece, 4), downPiece);
      expect(rotatePieceClockwise(downPiece, 4), leftPiece);
      expect(rotatePieceClockwise(leftPiece, 4), upPiece);
    });

    test('wallkicks when rotated off the field', () {
      final Piece downPiece = pieceFromString('RG0D');
      final Piece upPiece = pieceFromString('RG2U');
      final Piece expectedLeftPiece = pieceFromString('RG1L');
      final Piece expectedRightPiece = pieceFromString('RG1R');

      expect(rotatePieceClockwise(downPiece, 3), expectedLeftPiece);
      expect(rotatePieceClockwise(upPiece, 3), expectedRightPiece);
    });
  });
  group('rotate counter-clockwise', () {
    test('rotates around core puyo when there is room', () {
      final Piece upPiece = pieceFromString('RG2U');
      final Piece rightPiece = pieceFromString('RG2R');
      final Piece downPiece = pieceFromString('RG2D');
      final Piece leftPiece = pieceFromString('RG2L');

      expect(rotatePieceCounterclockwise(leftPiece, 4), downPiece);
      expect(rotatePieceCounterclockwise(downPiece, 4), rightPiece);
      expect(rotatePieceCounterclockwise(rightPiece, 4), upPiece);
      expect(rotatePieceCounterclockwise(upPiece, 4), leftPiece);
    });

    test('wallkicks when rotated off the field', () {
      final Piece downPiece = pieceFromString('RG2D');
      final Piece upPiece = pieceFromString('RG0U');
      final Piece expectedRightPiece = pieceFromString('RG1R');
      final Piece expectedLeftPiece = pieceFromString('RG1L');

      expect(rotatePieceCounterclockwise(downPiece, 3), expectedRightPiece);
      expect(rotatePieceCounterclockwise(upPiece, 3), expectedLeftPiece);
    });
  });

  group('string format conversion', () {
    test('piece string', () {
      expect(pieceString(pieceFromString('RG2U')), 'RG2U');
      expect(pieceString(pieceFromString('GB2R')), 'GB2R');
      expect(pieceString(pieceFromString('BY2D')), 'BY2D');
      expect(pieceString(pieceFromString('YR2L')), 'YR2L');
    });

    test('piece from string', () {
      final Piece upPiece = pieceFromString('RG0U');
      final Piece rightPiece = pieceFromString('GB1R');
      final Piece downPiece = pieceFromString('BY0D');
      final Piece leftPiece = pieceFromString('YR1L');
      final Piece expectedUpPiece = Piece((b) => b
        ..corePuyoColor = Color.red
        ..secondaryPuyoColor = Color.green
        ..corePuyoColumnIndex = 0
        ..orientation = Direction.up);
      final Piece expectedRightPiece = Piece((b) => b
        ..corePuyoColor = Color.green
        ..secondaryPuyoColor = Color.blue
        ..corePuyoColumnIndex = 1
        ..orientation = Direction.right);
      final Piece expectedDownPiece = Piece((b) => b
        ..corePuyoColor = Color.blue
        ..secondaryPuyoColor = Color.yellow
        ..corePuyoColumnIndex = 0
        ..orientation = Direction.down);
      final Piece expectedLeftPiece = Piece((b) => b
        ..corePuyoColor = Color.yellow
        ..secondaryPuyoColor = Color.red
        ..corePuyoColumnIndex = 1
        ..orientation = Direction.left);

      expect(upPiece, expectedUpPiece);
      expect(rightPiece, expectedRightPiece);
      expect(downPiece, expectedDownPiece);
      expect(leftPiece, expectedLeftPiece);
    });
  });
}
