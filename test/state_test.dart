import 'package:puyo/src/core/model/field.dart';
import 'package:puyo/src/core/model/piece.dart';
import 'package:puyo/src/core/model/piece_queue.dart';
import 'package:puyo/src/core/model/state.dart';
import 'package:test/test.dart';

void main() {
  group('player actions', () {
    test('move right', () {
      final State state = stateFromStrings(['EEEE\nEEEE', 'RG0R', 'GGBB']);
      final State expectedState =
          stateFromStrings(['EEEE\nEEEE', 'RG1R', 'GGBB']);

      expect(moveRight(state), expectedState);
    });

    test('move left', () {
      final State state = stateFromStrings(['EEEE\nEEEE', 'RG1R', 'GGBB']);
      final State expectedState =
          stateFromStrings(['EEEE\nEEEE', 'RG0R', 'GGBB']);

      expect(moveLeft(state), expectedState);
    });

    test('rotate clockwise', () {
      final State state = stateFromStrings(['EEEE\nEEEE', 'RG0R', 'GGBB']);
      final State expectedState =
          stateFromStrings(['EEEE\nEEEE', 'RG0D', 'GGBB']);

      expect(rotateClockwise(state), expectedState);
    });

    test('rotate counter-clockwise', () {
      final State state = stateFromStrings(['EEEE\nEEEE', 'RG0R', 'GGBB']);
      final State expectedState =
          stateFromStrings(['EEEE\nEEEE', 'RG0U', 'GGBB']);

      expect(rotateCounterclockwise(state), expectedState);
    });

    test('drop', () {
      final State state = stateFromStrings(['EEEE\nEEEE', 'RG0R', 'GGBB']);
      final State expectedState =
          stateFromStrings(['EEEE\nRGEE', 'GG2U', 'BBRR']);

      final State droppedState = drop(state);

      // Assert everything about the state except the newly generated nextNext
      // piece in the queue because it is random.
      expect(droppedState.field, expectedState.field);
      expect(droppedState.currentPiece, expectedState.currentPiece);
      expect(droppedState.pieceQueue.next, expectedState.pieceQueue.next);
    });
  });

  group('effects', () {
    test('chains', () {
      final State state = stateFromStrings(['ERGE\nRRRB', 'RG0R', 'GGBB']);
      final State expectedState =
          stateFromStrings(['EEGE\nEEEB', 'RG0R', 'GGBB']);

      expect(chains(state), expectedState);
    });

    test('gravity', () {
      final State state = stateFromStrings(['ERGE\nEEEB', 'RG0R', 'GGBB']);
      final State expectedState =
          stateFromStrings(['EEEE\nERGB', 'RG0R', 'GGBB']);

      expect(gravity(state), expectedState);
    });

    test('all chains', () {
      final State state =
          stateFromStrings(['RRBG\nGGBE\nGGRR', 'RG0R', 'GGBB']);
      // greens pop then reds pop, leaving blues and extra green left over.
      final State expectedState =
          stateFromStrings(['EEEE\nEEBE\nEEBG', 'RG0R', 'GGBB']);

      expect(allChains(state), expectedState);
    });
  });

  group('string format conversion', () {
    test('state string', () {
      final List<String> strings = ['EE\nEE', 'RG0R', 'BBYY'];

      expect(stateStrings(stateFromStrings(strings)), strings);
    });

    test('state from string', () {
      final State state = stateFromStrings(['EE\nEE', 'RG0R', 'BBYY']);
      final State expectedState = State((b) => b
        ..field = fieldFromString('EE\nEE').toBuilder()
        ..currentPiece = pieceFromString('RG0R').toBuilder()
        ..pieceQueue = pieceQueueFromString('BBYY').toBuilder());

      expect(state, expectedState);
    });
  });
}
