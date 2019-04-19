import 'package:built_collection/built_collection.dart';
import 'package:puyo/src/core/model/color.dart';
import 'package:puyo/src/core/model/direction.dart';
import 'package:puyo/src/core/model/piece.dart';
import 'package:test/test.dart';

void main() {
  test('new piece is pointed up in column 2 at the top of the field', () {
    final BuiltList<Color> colors = BuiltList([Color.red, Color.green]);
    final expectedPiece = pieceFromString('R,G,2,12,U');

    expect(newPiece(colors), expectedPiece);
  });

  test('has getters', () {
    final Piece piece = pieceFromString('R,G,0,0,R');

    expect(piece.colors, BuiltList<Color>([Color.red, Color.green]));
    expect(piece.secondaryPuyoColumnIndex, 1);
    expect(piece.columnIndexes, orderedEquals([0, 1]));
    expect(piece.rowIndexes, orderedEquals([0, 0]));
    expect(piece.colorProcessingOrder, orderedEquals([0, 1]));
  });

  test('processing order depends on direction', () {
    expect(pieceFromString('R,G,0,0,U').colorProcessingOrder,
        orderedEquals([0, 1]));
    expect(pieceFromString('R,G,0,0,D').colorProcessingOrder,
        orderedEquals([1, 0]));
    // Order does not matter for left or right orientations since the puyos
    // will not stack.
  });

  group('moves right', () {
    test('changes columns when there is room', () {
      final Piece piece = pieceFromString('R,G,0,0,R');
      final Piece expectedPiece = pieceFromString('R,G,1,0,R');

      expect(movePieceRight(piece, 3), expectedPiece);
    });

    test('wallkicks when moved off the field', () {
      final upPiece = pieceFromString('R,G,2,0,U');
      final rightPiece = pieceFromString('R,G,2,0,R');
      final downPiece = pieceFromString('R,G,2,0,D');
      final leftPiece = pieceFromString('R,G,3,0,L');

      expect(movePieceRight(upPiece, 3), upPiece);
      expect(movePieceRight(rightPiece, 4), rightPiece);
      expect(movePieceRight(downPiece, 3), downPiece);
      expect(movePieceRight(leftPiece, 4), leftPiece);
    });
  });

  group('move left', () {
    test('changes columns when there is room', () {
      final Piece piece = pieceFromString('R,G,1,0,R');
      final Piece expectedPiece = pieceFromString('R,G,0,0,R');

      expect(movePieceLeft(piece), expectedPiece);
    });

    test('wallkicks when moved off the field', () {
      final upPiece = pieceFromString('R,G,0,0,U');
      final rightPiece = pieceFromString('R,G,0,0,R');
      final downPiece = pieceFromString('R,G,0,0,D');
      final leftPiece = pieceFromString('R,G,1,0,L');

      expect(movePieceLeft(upPiece), upPiece);
      expect(movePieceLeft(rightPiece), rightPiece);
      expect(movePieceLeft(downPiece), downPiece);
      expect(movePieceLeft(leftPiece), leftPiece);
    });
  });

  group('rotate clockwise', () {
    test('rotates around core puyo when there is room', () {
      final Piece upPiece = pieceFromString('R,G,2,1,U');
      final Piece rightPiece = pieceFromString('R,G,2,1,R');
      final Piece downPiece = pieceFromString('R,G,2,1,D');
      final Piece leftPiece = pieceFromString('R,G,2,1,L');

      expect(rotatePieceClockwise(upPiece, 4), rightPiece);
      expect(rotatePieceClockwise(rightPiece, 4), downPiece);
      expect(rotatePieceClockwise(downPiece, 4), leftPiece);
      expect(rotatePieceClockwise(leftPiece, 4), upPiece);
    });

    test('wallkicks when rotated off the field', () {
      final Piece downPiece = pieceFromString('R,G,0,1,D');
      final Piece upPiece = pieceFromString('R,G,2,1,U');
      final Piece expectedLeftPiece = pieceFromString('R,G,1,1,L');
      final Piece expectedRightPiece = pieceFromString('R,G,1,1,R');

      expect(rotatePieceClockwise(downPiece, 3), expectedLeftPiece);
      expect(rotatePieceClockwise(upPiece, 3), expectedRightPiece);
    });
  });
  group('rotate counter-clockwise', () {
    test('rotates around core puyo when there is room', () {
      final Piece upPiece = pieceFromString('R,G,2,1,U');
      final Piece rightPiece = pieceFromString('R,G,2,1,R');
      final Piece downPiece = pieceFromString('R,G,2,1,D');
      final Piece leftPiece = pieceFromString('R,G,2,1,L');

      expect(rotatePieceCounterclockwise(leftPiece, 4), downPiece);
      expect(rotatePieceCounterclockwise(downPiece, 4), rightPiece);
      expect(rotatePieceCounterclockwise(rightPiece, 4), upPiece);
      expect(rotatePieceCounterclockwise(upPiece, 4), leftPiece);
    });

    test('wallkicks when rotated off the field', () {
      final Piece downPiece = pieceFromString('R,G,2,1,D');
      final Piece upPiece = pieceFromString('R,G,0,1,U');
      final Piece expectedRightPiece = pieceFromString('R,G,1,1,R');
      final Piece expectedLeftPiece = pieceFromString('R,G,1,1,L');

      expect(rotatePieceCounterclockwise(downPiece, 3), expectedRightPiece);
      expect(rotatePieceCounterclockwise(upPiece, 3), expectedLeftPiece);
    });
  });

  group('string format conversion', () {
    test('piece string', () {
      expect(pieceString(pieceFromString('R,G,2,5,U')), 'R,G,2,5,U');
      expect(pieceString(pieceFromString('G,B,2,5,R')), 'G,B,2,5,R');
      expect(pieceString(pieceFromString('B,Y,2,5,D')), 'B,Y,2,5,D');
      expect(pieceString(pieceFromString('Y,R,2,5,L')), 'Y,R,2,5,L');
    });

    test('piece from string', () {
      final Piece upPiece = pieceFromString('R,G,0,5,U');
      final Piece rightPiece = pieceFromString('G,B,1,5,R');
      final Piece downPiece = pieceFromString('B,Y,10,5,D');
      final Piece leftPiece = pieceFromString('Y,R,1,10,L');
      final Piece expectedUpPiece = Piece((b) => b
        ..corePuyoColor = Color.red
        ..secondaryPuyoColor = Color.green
        ..corePuyoColumnIndex = 0
        ..corePuyoRowIndex = 5
        ..orientation = Direction.up);
      final Piece expectedRightPiece = Piece((b) => b
        ..corePuyoColor = Color.green
        ..secondaryPuyoColor = Color.blue
        ..corePuyoColumnIndex = 1
        ..corePuyoRowIndex = 5
        ..orientation = Direction.right);
      final Piece expectedDownPiece = Piece((b) => b
        ..corePuyoColor = Color.blue
        ..secondaryPuyoColor = Color.yellow
        ..corePuyoColumnIndex = 10
        ..corePuyoRowIndex = 5
        ..orientation = Direction.down);
      final Piece expectedLeftPiece = Piece((b) => b
        ..corePuyoColor = Color.yellow
        ..secondaryPuyoColor = Color.red
        ..corePuyoColumnIndex = 1
        ..corePuyoRowIndex = 10
        ..orientation = Direction.left);

      expect(upPiece, expectedUpPiece);
      expect(rightPiece, expectedRightPiece);
      expect(downPiece, expectedDownPiece);
      expect(leftPiece, expectedLeftPiece);
    });
  });
}
