import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:puyo/src/core/model/common.dart';

part 'piece_queue.g.dart';

// TODO: rethink randomness

abstract class PieceQueue implements Built<PieceQueue, PieceQueueBuilder> {
  BuiltList<Color> get next;

  BuiltList<Color> get nextNext;

  PieceQueue._();

  factory PieceQueue([updates(PieceQueueBuilder b)]) = _$PieceQueue;
}

final PieceQueue startingQueue = PieceQueue((b) => b
  ..next = _generateColorPair().toBuilder()
  ..nextNext = _generateColorPair().toBuilder());

PieceQueue advanceQueue(PieceQueue queue) => queue.rebuild((b) => b
  ..next = b.nextNext
  ..nextNext = _generateColorPair().toBuilder());

BuiltList<Color> _generateColorPair() => BuiltList([
      Color.values[Random().nextInt(Color.values.length)],
      Color.values[Random().nextInt(Color.values.length)]
    ]);

String pieceQueueString(PieceQueue pieceQueue) =>
    (List.of(pieceQueue.next)..addAll(pieceQueue.nextNext))
        .map((color) => characterByColor[color])
        .join();

PieceQueue pieceQueueFromString(String pieceQueueString) => PieceQueue((b) => b
  ..next = ListBuilder<Color>(pieceQueueString
      .substring(0, 2)
      .split('')
      .map((colorString) => colorByCharacter[colorString]))
  ..nextNext = ListBuilder<Color>(pieceQueueString
      .substring(2, 4)
      .split('')
      .map((colorString) => colorByCharacter[colorString])));
