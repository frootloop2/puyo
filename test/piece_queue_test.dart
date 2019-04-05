import 'package:puyo/src/core/model/piece_queue.dart';
import 'package:test/test.dart';

void main() {
  test('advances queue', () {
    PieceQueue advancedQueue = advanceQueue(startingQueue);
    expect(startingQueue.nextNext, equals(advancedQueue.next));
  });
}
