import 'package:built_collection/built_collection.dart';
import 'package:puyo/src/core/model/color.dart';
import 'package:puyo/src/core/model/piece_queue.dart';
import 'package:test/test.dart';

void main() {
  test('advances queue', () {
    final PieceQueue advancedQueue = advanceQueue(startingQueue);
    expect(startingQueue.nextNext, equals(advancedQueue.next));
  });

  test('piece queue string', () {
    expect(pieceQueueString(pieceQueueFromString('RGBY')), 'RGBY');
  });

  test('piece queue from string', () {
    final PieceQueue expectedPieceQueue = PieceQueue((b) => b
      ..next = ListBuilder<Color>([Color.red, Color.green])
      ..nextNext = ListBuilder<Color>([Color.blue, Color.yellow]));

    expect(pieceQueueFromString('RGBY'), expectedPieceQueue);
  });
}
