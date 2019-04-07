import 'package:built_collection/built_collection.dart';
import 'package:puyo/src/core/model/common.dart';
import 'package:puyo/src/core/model/piece.dart';
import 'package:test/test.dart';

void main() {
  group('default red-blue piece', () {
    final BuiltList<Color> colors = BuiltList([Color.red, Color.blue]);

    final Piece upPiece = Piece((b) => b
      ..corePuyoColor = colors.first
      ..secondaryPuyoColor = colors.last
      ..corePuyoColumnIndex = 2
      ..orientation = Direction.up);
    final Piece rightPiece =
        upPiece.rebuild((b) => b.orientation = Direction.right);
    final Piece downPiece =
        upPiece.rebuild((b) => b.orientation = Direction.down);
    final Piece leftPiece =
        upPiece.rebuild((b) => b.orientation = Direction.left);

    test('new piece is pointed up in column 2', () {
      expect(newPiece(colors), upPiece);
    });

    test('has getters', () {
      expect(rightPiece.colors, colors);
      expect(rightPiece.secondaryPuyoColumnIndex, 3);
      expect(rightPiece.columnIndexes, orderedEquals([2, 3]));
      expect(rightPiece.colorProcessingOrder, orderedEquals([0, 1]));
    });

    test('processing order depends on direction', () {
      expect(upPiece.colorProcessingOrder, orderedEquals([0, 1]));
      expect(downPiece.colorProcessingOrder, orderedEquals([1, 0]));
      // Order does not matter for left or right orientations since the puyos
      // will not stack.
    });

    group('moves right', () {
      test('changes columns when there is room', () {
        final Piece movedRightPiece =
            movePieceRight(upPiece, upPiece.corePuyoColumnIndex + 2);
        expect(
            movedRightPiece.columnIndexes,
            orderedEquals([
              upPiece.columnIndexes.first + 1,
              upPiece.columnIndexes.last + 1
            ]));
      });

      test('wallkicks when moved off the field', () {
        expect(
            movePieceRight(upPiece, upPiece.corePuyoColumnIndex + 1), upPiece);

        expect(
            movePieceRight(
                rightPiece,
                // secondary puyo is rightmost
                rightPiece.secondaryPuyoColumnIndex + 1),
            rightPiece);

        expect(movePieceRight(downPiece, downPiece.corePuyoColumnIndex + 1),
            downPiece);

        expect(movePieceRight(leftPiece, leftPiece.corePuyoColumnIndex + 1),
            leftPiece);
      });
    });

    group('move left', () {
      test('changes columns when there is room', () {
        final Piece movedLeftPiece = movePieceLeft(upPiece);
        expect(
            movedLeftPiece.columnIndexes,
            orderedEquals([
              upPiece.columnIndexes.first - 1,
              upPiece.columnIndexes.last - 1
            ]));
      });

      test('wallkicks when moved off the field', () {
        final Piece upPieceAtLeftWall =
            upPiece.rebuild((b) => b..corePuyoColumnIndex = 0);
        expect(movePieceLeft(upPieceAtLeftWall), upPieceAtLeftWall);

        final Piece rightPieceAtLeftWall =
            rightPiece.rebuild((b) => b..corePuyoColumnIndex = 0);
        expect(movePieceLeft(rightPieceAtLeftWall), rightPieceAtLeftWall);

        final Piece downPieceAtLeftWall =
            downPiece.rebuild((b) => b..corePuyoColumnIndex = 0);
        expect(movePieceLeft(downPieceAtLeftWall), downPieceAtLeftWall);

        // secondary puyo is leftmost
        final Piece leftPieceAtLeftWall =
            leftPiece.rebuild((b) => b..corePuyoColumnIndex = 1);
        expect(movePieceLeft(leftPieceAtLeftWall), leftPieceAtLeftWall);
      });
    });

    group('rotate clockwise', () {
      test('rotates around core puyo when there is room', () {
        final int fieldSize = upPiece.corePuyoColumnIndex + 2;

        final Piece rightPiece = rotatePieceClockwise(upPiece, fieldSize);
        expect(rightPiece.orientation, Direction.right);
        expect(
            rightPiece.columnIndexes,
            orderedEquals([
              upPiece.corePuyoColumnIndex,
              upPiece.secondaryPuyoColumnIndex + 1
            ]));

        final Piece downPiece = rotatePieceClockwise(rightPiece, fieldSize);
        expect(downPiece.orientation, Direction.down);
        expect(
            downPiece.columnIndexes,
            orderedEquals([
              upPiece.corePuyoColumnIndex,
              upPiece.secondaryPuyoColumnIndex
            ]));

        final Piece leftPiece = rotatePieceClockwise(downPiece, fieldSize);
        expect(leftPiece.orientation, Direction.left);
        expect(
            leftPiece.columnIndexes,
            orderedEquals([
              upPiece.corePuyoColumnIndex,
              upPiece.secondaryPuyoColumnIndex - 1
            ]));

        expect(rotatePieceClockwise(leftPiece, fieldSize), upPiece);
      });

      test('wallkicks when rotated off the field', () {
        final Piece upPieceRotatedClockwiseAtRightWall =
            rotatePieceClockwise(upPiece, upPiece.corePuyoColumnIndex + 1);
        expect(upPieceRotatedClockwiseAtRightWall.orientation, Direction.right);
        expect(upPieceRotatedClockwiseAtRightWall.corePuyoColumnIndex,
            upPiece.corePuyoColumnIndex - 1);

        final Piece downPieceAtLeftWall =
            downPiece.rebuild((b) => b..corePuyoColumnIndex = 0);
        final Piece downPieceRotatedClockwiseAtLeftWall = rotatePieceClockwise(
            downPieceAtLeftWall, downPieceAtLeftWall.corePuyoColumnIndex + 1);
        expect(downPieceRotatedClockwiseAtLeftWall.orientation, Direction.left);
        expect(downPieceRotatedClockwiseAtLeftWall.corePuyoColumnIndex,
            downPieceAtLeftWall.corePuyoColumnIndex + 1);
      });
    });
    group('rotate counter-clockwise', () {
      test('rotates around core puyo when there is room', () {
        final int fieldSize = upPiece.corePuyoColumnIndex + 2;

        final Piece leftPiece = rotatePieceCounterClockwise(upPiece, fieldSize);
        expect(leftPiece.orientation, Direction.left);
        expect(
            leftPiece.columnIndexes,
            orderedEquals([
              upPiece.corePuyoColumnIndex,
              upPiece.secondaryPuyoColumnIndex - 1
            ]));

        final Piece downPiece =
            rotatePieceCounterClockwise(leftPiece, fieldSize);
        expect(downPiece.orientation, Direction.down);
        expect(
            downPiece.columnIndexes,
            orderedEquals([
              upPiece.corePuyoColumnIndex,
              upPiece.secondaryPuyoColumnIndex
            ]));

        final Piece rightPiece =
            rotatePieceCounterClockwise(downPiece, fieldSize);
        expect(rightPiece.orientation, Direction.right);
        expect(
            rightPiece.columnIndexes,
            orderedEquals([
              upPiece.corePuyoColumnIndex,
              upPiece.secondaryPuyoColumnIndex + 1
            ]));

        expect(rotatePieceCounterClockwise(rightPiece, fieldSize), upPiece);
      });

      test('wallkicks when rotated off the field', () {
        final Piece downPieceRotatedCounterClockwiseAtRightWall =
            rotatePieceCounterClockwise(
                downPiece, downPiece.corePuyoColumnIndex + 1);
        expect(downPieceRotatedCounterClockwiseAtRightWall.orientation,
            Direction.right);
        expect(downPieceRotatedCounterClockwiseAtRightWall.corePuyoColumnIndex,
            downPiece.corePuyoColumnIndex - 1);

        final Piece upPieceAtLeftWall =
            upPiece.rebuild((b) => b..corePuyoColumnIndex = 0);
        final Piece upPieceRotatedCounterClockwiseAtLeftWall =
            rotatePieceCounterClockwise(
                upPieceAtLeftWall, upPieceAtLeftWall.corePuyoColumnIndex + 1);
        expect(upPieceRotatedCounterClockwiseAtLeftWall.orientation,
            Direction.left);
        expect(upPieceRotatedCounterClockwiseAtLeftWall.corePuyoColumnIndex,
            upPieceAtLeftWall.corePuyoColumnIndex + 1);
      });
    });

    test('piece string', () {
      expect(pieceString(upPiece),
          'color: R, column: 2\ncolor: B, column: 2\norientation: U');
    });
  });
}
