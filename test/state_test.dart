import 'package:puyo/src/core/model/field.dart';
import 'package:puyo/src/core/model/piece.dart';
import 'package:puyo/src/core/model/piece_queue.dart';
import 'package:puyo/src/core/model/state.dart';
import 'package:test/test.dart';

void main() {
  group('queries', () {
    test('is not lost', () {
      final State state = stateFromStrings(
          ['EEEEEE\nEEEEEE\nRRERRR\nGGGBBB', 'R,G,0,1,R', 'GGBB', '0', '0']);

      expect(isLost(state), isFalse);
    });

    test('is lost', () {
      final State state =
          stateFromStrings(['EEREEE\nEEREEE', 'R,G,0,1,R', 'GGBB', '0', '0']);

      expect(isLost(state), isTrue);
    });
  });

  group('player actions', () {
    test('move right', () {
      final State state =
          stateFromStrings(['EEEE\nEEEE', 'R,G,0,1,R', 'GGBB', '3', '0']);
      final State expectedState =
          stateFromStrings(['EEEE\nEEEE', 'R,G,1,1,R', 'GGBB', '3', '0']);

      expect(moveRight(state), expectedState);
    });

    test('move left', () {
      final State state =
          stateFromStrings(['EEEE\nEEEE', 'R,G,1,1,R', 'GGBB', '3', '0']);
      final State expectedState =
          stateFromStrings(['EEEE\nEEEE', 'R,G,0,1,R', 'GGBB', '3', '0']);

      expect(moveLeft(state), expectedState);
    });

    test('rotate clockwise', () {
      final State state =
          stateFromStrings(['EEEE\nEEEE', 'R,G,0,1,R', 'GGBB', '3', '0']);
      final State expectedState =
          stateFromStrings(['EEEE\nEEEE', 'R,G,0,1,D', 'GGBB', '3', '0']);

      expect(rotateClockwise(state), expectedState);
    });

    test('rotate counter-clockwise', () {
      final State state =
          stateFromStrings(['EEEE\nEEEE', 'R,G,0,0,R', 'GGBB', '3', '0']);
      final State expectedState =
          stateFromStrings(['EEEE\nEEEE', 'R,G,0,0,U', 'GGBB', '3', '0']);

      expect(rotateCounterclockwise(state), expectedState);
    });

    test('drop', () {
      final State state =
          stateFromStrings(['EEEE\nEEEE\nEEEE', 'R,G,0,1,R', 'GGBB', '0', '4']);
      final State expectedState = stateFromStrings(
          ['EEEE\nEEEE\nRGEE', 'G,G,2,12,U', 'BBRR', '0', '4']);

      final State droppedState = drop(state);

      // Assert everything about the state except the newly generated nextNext
      // piece in the queue because it is random.
      expect(droppedState.field, expectedState.field);
      expect(droppedState.currentPiece, expectedState.currentPiece);
      expect(droppedState.pieceQueue.next, expectedState.pieceQueue.next);
      expect(droppedState.pendingTrash, expectedState.pendingTrash);
    });
  });

  group('effects', () {
    test('chains', () {
      final State state =
          stateFromStrings(['ERGE\nRRRB', 'R,G,0,1,R', 'GGBB', '3', '0']);
      final State expectedState =
          stateFromStrings(['EEGE\nEEEB', 'R,G,0,1,R', 'GGBB', '3', '0']);

      expect(chains(state), expectedState);
    });

    test('gravity', () {
      final State state =
          stateFromStrings(['ERGE\nEEEB', 'R,G,0,1,R', 'GGBB', '3', '0']);
      final State expectedState =
          stateFromStrings(['EEEE\nERGB', 'R,G,0,1,R', 'GGBB', '3', '0']);

      expect(gravity(state), expectedState);
    });

    test('all chains', () {
      final State state =
          stateFromStrings(['RRBG\nGGBE\nGGRR', 'R,G,0,1,R', 'GGBB', '3', '0']);
      // greens pop then reds pop, leaving blues and extra green left over.
      final State expectedState = stateFromStrings(
          ['EEEE\nEEBE\nEEBG', 'R,G,0,1,R', 'GGBB', '3', '12']);

      expect(allChains(state), expectedState);
    });

    test('trash', () {
      final State state = stateFromStrings(
          ['EEEE\nEEEE\nEEEE\nEERR\nGGBB', 'R,G,0,1,R', 'GGBB', '4', '0']);
      final State expectedState = stateFromStrings(
          ['EEEE\nEEEE\nEETT\nTTRR\nGGBB', 'R,G,0,1,R', 'GGBB', '0', '0']);
      expect(trash(state), expectedState);
    });
  });

  group('string format conversion', () {
    test('state string', () {
      final List<String> strings = ['EE\nEE', 'R,G,0,1,R', 'BBYY', '3', '6'];

      expect(stateStrings(stateFromStrings(strings)), strings);
    });

    test('state from string', () {
      final State state =
          stateFromStrings(['EE\nEE', 'R,G,0,1,R', 'BBYY', '3', '0']);
      final State expectedState = State((b) => b
        ..field = fieldFromString('EE\nEE').toBuilder()
        ..currentPiece = pieceFromString('R,G,0,1,R').toBuilder()
        ..pieceQueue = pieceQueueFromString('BBYY').toBuilder()
        ..pendingTrash = 3
        ..outgoingTrash = 0);

      expect(state, expectedState);
    });
  });
}
