import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:puyo/src/core/model/common.dart';

part 'piece.g.dart';

final BuiltList<Direction> _clockwiseRotationOrder =
    BuiltList([Direction.up, Direction.right, Direction.down, Direction.left]);

abstract class Piece implements Built<Piece, PieceBuilder> {
  Color get corePuyoColor;

  Color get secondaryPuyoColor;

  int get corePuyoColumnIndex;

  Direction get orientation;

  BuiltList<Color> get colors => BuiltList([corePuyoColor, secondaryPuyoColor]);

  BuiltList<int> get columnIndexes =>
      BuiltList([corePuyoColumnIndex, secondaryPuyoColumnIndex]);

  int get secondaryPuyoColumnIndex {
    switch (orientation) {
      case Direction.up:
      case Direction.down:
        return corePuyoColumnIndex;
      case Direction.right:
        return corePuyoColumnIndex + 1;
      case Direction.left:
        return corePuyoColumnIndex - 1;
      default:
        return 0; // impossible
    }
  }

  BuiltList<int> get colorProcessingOrder =>
      BuiltList(orientation == Direction.down ? [1, 0] : [0, 1]);

  Piece._();

  factory Piece([updates(PieceBuilder b)]) = _$Piece;
}

Piece movePieceRight(Piece piece, int columnCount) =>
    piece.rebuild((b) => b.corePuyoColumnIndex = min(b.corePuyoColumnIndex + 1,
        columnCount - (piece.orientation == Direction.right ? 2 : 1)));

Piece movePieceLeft(Piece piece) =>
    piece.rebuild((b) => b.corePuyoColumnIndex = max(b.corePuyoColumnIndex - 1,
        (piece.orientation == Direction.left ? 1 : 0)));

Piece rotatePieceClockwise(Piece piece, int columnCount) {
  PieceBuilder builder = piece.toBuilder();
  builder.orientation = _clockwiseRotationOrder[
      (_clockwiseRotationOrder.indexOf(piece.orientation) + 1) %
          _clockwiseRotationOrder.length];

  // wallkicks
  if (builder.orientation == Direction.left) {
    builder.corePuyoColumnIndex = max(builder.corePuyoColumnIndex, 1);
  }
  if (builder.orientation == Direction.right) {
    builder.corePuyoColumnIndex =
        min(builder.corePuyoColumnIndex, columnCount - 2);
  }
  return builder.build();
}

Piece rotatePieceCounterclockwise(Piece piece, int columnCount) {
  PieceBuilder builder = piece.toBuilder();
  builder.orientation = _clockwiseRotationOrder[
      (_clockwiseRotationOrder.indexOf(piece.orientation) - 1) %
          _clockwiseRotationOrder.length];

  // wallkicks
  if (builder.orientation == Direction.left) {
    builder.corePuyoColumnIndex = max(builder.corePuyoColumnIndex, 1);
  }
  if (builder.orientation == Direction.right) {
    builder.corePuyoColumnIndex =
        min(builder.corePuyoColumnIndex, columnCount - 2);
  }
  return builder.build();
}

Piece newPiece(BuiltList<Color> colors) => Piece((b) => b
  ..corePuyoColor = colors.first
  ..secondaryPuyoColor = colors.last
  ..corePuyoColumnIndex = 2
  ..orientation = Direction.up);

String pieceString(Piece piece) => '${characterByColor[piece.corePuyoColor]}'
    '${characterByColor[piece.secondaryPuyoColor]}'
    '${piece.corePuyoColumnIndex}'
    '${characterByDirection[piece.orientation]}';

Piece pieceFromString(String pieceString) => Piece((b) => b
  ..corePuyoColor = colorByCharacter[pieceString.substring(0, 1)]
  ..secondaryPuyoColor = colorByCharacter[pieceString.substring(1, 2)]
  ..corePuyoColumnIndex = int.parse(pieceString.substring(2, 3))
  ..orientation = directionByCharacter[pieceString.substring(3, 4)]);
