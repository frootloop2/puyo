import 'package:built_collection/built_collection.dart';
import 'package:puyo/src/core/model/common.dart';
import 'package:puyo/src/core/model/piece.dart';
import 'package:test/test.dart';

void main() {
  group('default red-blue piece', () {
    final BuiltList<Color> colors = BuiltList([Color.red, Color.blue]);
    final Piece defaultPiece = Piece((b) => b
      ..corePuyoColor = colors.first
      ..secondaryPuyoColor = colors.last
      ..corePuyoColumnIndex = 2
      ..orientation = Direction.up);

    test('matches new piece', () {
      final Piece generatedPiece = newPiece(colors);
      expect(generatedPiece, equals(defaultPiece));
    });

    test('has getters', () {
      expect(defaultPiece.colors, equals(colors));
      expect(defaultPiece.secondaryPuyoColumnIndex, equals(2));
      expect(defaultPiece.columnIndexes, equals(BuiltList<int>([2, 2])));
      expect(defaultPiece.colorProcessingOrder, equals(BuiltList<int>([0, 1])));
    });

    group('moves right', () {
      test('when not blocked by edge of field', () {
        final Piece movedRightPiece =
            movePieceRight(defaultPiece, defaultPiece.corePuyoColumnIndex + 2);
        expect(
            movedRightPiece.columnIndexes,
            equals(BuiltList<int>([
              defaultPiece.columnIndexes.first + 1,
              defaultPiece.columnIndexes.last + 1
            ])));
      });

      test('is blocked by edge of field', () {
        final Piece movedRightPiece =
            movePieceRight(defaultPiece, defaultPiece.corePuyoColumnIndex + 1);
        expect(movedRightPiece, defaultPiece);
      });
    });

    group('move left', () {
      test('when not blocked by edge of field', () {
        final Piece movedLeftPiece = movePieceLeft(defaultPiece);
        expect(
            movedLeftPiece.columnIndexes,
            equals(BuiltList<int>([
              defaultPiece.columnIndexes.first - 1,
              defaultPiece.columnIndexes.last - 1
            ])));
      });

      test('is blocked by edge of field', () {
        final Piece pieceAtWall =
            defaultPiece.rebuild((b) => b..corePuyoColumnIndex = 0);
        final Piece movedLeftPiece = movePieceLeft(pieceAtWall);
        expect(movedLeftPiece, equals(pieceAtWall));
      });
    });
  });
}
