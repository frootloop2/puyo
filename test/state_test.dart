import 'package:puyo/src/core/model/field.dart';
import 'package:puyo/src/core/model/piece.dart';
import 'package:puyo/src/core/model/piece_queue.dart';
import 'package:puyo/src/core/model/state.dart';
import 'package:test/test.dart';

void main() {
  group('queries', () {
    test('is not lost', () {
      final State state =
          stateFromStrings(['RRERRR\nGGGBBB', 'RG0R', 'GGBB', '0', '0']);

      expect(isLost(state), isFalse);
    });

    test('is lost', () {
      final State state =
          stateFromStrings(['EEREEE\nEEREEE', 'RG0R', 'GGBB', '0', '0']);

      expect(isLost(state), isTrue);
    });
  });

  group('player actions', () {
    test('move right', () {
      final State state =
          stateFromStrings(['EEEE\nEEEE', 'RG0R', 'GGBB', '3', '0']);
      final State expectedState =
          stateFromStrings(['EEEE\nEEEE', 'RG1R', 'GGBB', '3', '0']);

      expect(moveRight(state), expectedState);
    });

    test('move left', () {
      final State state =
          stateFromStrings(['EEEE\nEEEE', 'RG1R', 'GGBB', '3', '0']);
      final State expectedState =
          stateFromStrings(['EEEE\nEEEE', 'RG0R', 'GGBB', '3', '0']);

      expect(moveLeft(state), expectedState);
    });

    test('rotate clockwise', () {
      final State state =
          stateFromStrings(['EEEE\nEEEE', 'RG0R', 'GGBB', '3', '0']);
      final State expectedState =
          stateFromStrings(['EEEE\nEEEE', 'RG0D', 'GGBB', '3', '0']);

      expect(rotateClockwise(state), expectedState);
    });

    test('rotate counter-clockwise', () {
      final State state =
          stateFromStrings(['EEEE\nEEEE', 'RG0R', 'GGBB', '3', '0']);
      final State expectedState =
          stateFromStrings(['EEEE\nEEEE', 'RG0U', 'GGBB', '3', '0']);

      expect(rotateCounterclockwise(state), expectedState);
    });

    test('drop', () {
      final State state =
          stateFromStrings(['EEEE\nEEEE', 'RG0R', 'GGBB', '0', '4']);
      final State expectedState =
          stateFromStrings(['EEEE\nRGEE', 'GG2U', 'BBRR', '0', '4']);

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
          stateFromStrings(['ERGE\nRRRB', 'RG0R', 'GGBB', '3', '0']);
      final State expectedState =
          stateFromStrings(['EEGE\nEEEB', 'RG0R', 'GGBB', '3', '0']);

      expect(chains(state), expectedState);
    });

    test('gravity', () {
      final State state =
          stateFromStrings(['ERGE\nEEEB', 'RG0R', 'GGBB', '3', '0']);
      final State expectedState =
          stateFromStrings(['EEEE\nERGB', 'RG0R', 'GGBB', '3', '0']);

      expect(gravity(state), expectedState);
    });

    test('all chains', () {
      final State state =
          stateFromStrings(['RRBG\nGGBE\nGGRR', 'RG0R', 'GGBB', '3', '0']);
      // greens pop then reds pop, leaving blues and extra green left over.
      final State expectedState =
          stateFromStrings(['EEEE\nEEBE\nEEBG', 'RG0R', 'GGBB', '3', '12']);

      expect(allChains(state), expectedState);
    });

    test('trash', () {
      final State state =
          stateFromStrings(['EEEE\nEERR\nGGBB', 'RG0R', 'GGBB', '4', '0']);
      final State expectedState =
          stateFromStrings(['EETT\nTTRR\nGGBB', 'RG0R', 'GGBB', '0', '0']);
      expect(trash(state), expectedState);
    });
  });

  group('string format conversion', () {
    test('state string', () {
      final List<String> strings = ['EE\nEE', 'RG0R', 'BBYY', '3', '6'];

      expect(stateStrings(stateFromStrings(strings)), strings);
    });

    test('state from string', () {
      final State state =
          stateFromStrings(['EE\nEE', 'RG0R', 'BBYY', '3', '0']);
      final State expectedState = State((b) => b
        ..field = fieldFromString('EE\nEE').toBuilder()
        ..currentPiece = pieceFromString('RG0R').toBuilder()
        ..pieceQueue = pieceQueueFromString('BBYY').toBuilder()
        ..pendingTrash = 3
        ..outgoingTrash = 0);

      expect(state, expectedState);
    });
  });
}
