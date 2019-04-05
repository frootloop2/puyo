import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:puyo/src/core/model/common.dart';

part 'piece_queue.g.dart';

abstract class PieceQueue implements Built<PieceQueue, PieceQueueBuilder> {
  BuiltList<Color> get next;

  BuiltList<Color> get nextNext;

  PieceQueue._();

  factory PieceQueue([updates(PieceQueueBuilder b)]) = _$PieceQueue;
}

final PieceQueue startingQueue = PieceQueue((b) => b
  ..next = generateColorPair().toBuilder()
  ..nextNext = generateColorPair().toBuilder());

PieceQueue advanceQueue(PieceQueue queue) => queue.rebuild((b) => b
  ..next = b.nextNext
  ..nextNext = generateColorPair().toBuilder());

BuiltList<Color> generateColorPair() => BuiltList([
      Color.values[Random().nextInt(Color.values.length)],
      Color.values[Random().nextInt(Color.values.length)]
    ]);
