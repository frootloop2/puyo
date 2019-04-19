import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:puyo/src/core/model/field.dart';
import 'package:puyo/src/core/model/piece.dart';
import 'package:puyo/src/core/model/piece_queue.dart';

part 'state.g.dart';

abstract class State implements Built<State, StateBuilder> {
  static Serializer<State> get serializer => _$stateSerializer;

  PieceQueue get pieceQueue;

  Field get field;

  Piece get currentPiece;

  int get pendingTrash;

  int get outgoingTrash;

  State._();

  factory State([updates(StateBuilder b)]) = _$State;
}

final State initialState = State((b) => b
  ..pieceQueue = advanceQueue(startingQueue).toBuilder()
  ..field = emptyField.toBuilder()
  ..currentPiece = newPiece(startingQueue.next).toBuilder()
  ..pendingTrash = 0
  ..outgoingTrash = 0);

State moveRight(State state) {
  final bool corePuyoCanMoveRight =
      (state.currentPiece.corePuyoColumnIndex < state.field.columnCount - 1) &&
          isCellEmpty(state.field, state.currentPiece.corePuyoColumnIndex + 1,
              state.currentPiece.corePuyoRowIndex);
  final bool secondaryPuyoCanMoveRight =
      (state.currentPiece.secondaryPuyoColumnIndex <
              state.field.columnCount - 1) &&
          isCellEmpty(
              state.field,
              state.currentPiece.secondaryPuyoColumnIndex + 1,
              state.currentPiece.secondaryPuyoRowIndex);
  if (corePuyoCanMoveRight && secondaryPuyoCanMoveRight) {
    return state.rebuild((b) => b.currentPiece =
        movePieceRight(state.currentPiece, state.field.columnCount)
            .toBuilder());
  } else {
    return state;
  }
}

State moveLeft(State state) {
  final bool corePuyoCanMoveLeft =
      (state.currentPiece.corePuyoColumnIndex > 0) &&
          isCellEmpty(state.field, state.currentPiece.corePuyoColumnIndex - 1,
              state.currentPiece.corePuyoRowIndex);
  final bool secondaryPuyoCanMoveLeft =
      (state.currentPiece.secondaryPuyoColumnIndex > 0) &&
          isCellEmpty(
              state.field,
              state.currentPiece.secondaryPuyoColumnIndex - 1,
              state.currentPiece.secondaryPuyoRowIndex);
  if (corePuyoCanMoveLeft && secondaryPuyoCanMoveLeft) {
    return state.rebuild(
        (b) => b.currentPiece = movePieceLeft(state.currentPiece).toBuilder());
  } else {
    return state;
  }
}

State rotateClockwise(State state) => state.rebuild((b) {
      Piece piece =
          rotatePieceClockwise(state.currentPiece, state.field.columnCount);
      bool pieceFits = isCellEmpty(
              state.field, piece.corePuyoColumnIndex, piece.corePuyoRowIndex) &&
          isCellEmpty(state.field, piece.secondaryPuyoColumnIndex,
              piece.secondaryPuyoRowIndex);
      if (pieceFits) {
        b.currentPiece = piece.toBuilder();
      } else {
        // kicks
      }
    });

State rotateCounterclockwise(State state) => state.rebuild((b) {
      Piece piece = rotatePieceCounterclockwise(
          state.currentPiece, state.field.columnCount);
      bool pieceFits = isCellEmpty(
              state.field, piece.corePuyoColumnIndex, piece.corePuyoRowIndex) &&
          isCellEmpty(state.field, piece.secondaryPuyoColumnIndex,
              piece.secondaryPuyoRowIndex);
      if (pieceFits) {
        b.currentPiece = piece.toBuilder();
      } else {
        // kicks
      }
    });

State dropOnce(State state) {
  final bool corePuyoCanMoveDown = (state.currentPiece.corePuyoRowIndex > 0) &&
      isCellEmpty(state.field, state.currentPiece.corePuyoColumnIndex,
          state.currentPiece.corePuyoRowIndex - 1);
  final bool secondaryPuyoCanMoveDown =
      (state.currentPiece.secondaryPuyoRowIndex > 0) &&
          isCellEmpty(state.field, state.currentPiece.secondaryPuyoColumnIndex,
              state.currentPiece.secondaryPuyoRowIndex - 1);
  if (corePuyoCanMoveDown && secondaryPuyoCanMoveDown) {
    return state.rebuild((b) => b.currentPiece.corePuyoRowIndex--);
  } else {
    return trash(allChains(drop(state)));
  }
}

State drop(State state) =>
    dropPiece(state.field, state.currentPiece) == state.field
        ? state
        : state.rebuild((b) => b
          ..field = dropPiece(state.field, state.currentPiece).toBuilder()
          ..currentPiece = newPiece(state.pieceQueue.next).toBuilder()
          ..pieceQueue = advanceQueue(state.pieceQueue).toBuilder());

State chains(State state) =>
    state.rebuild((b) => b..field = removeChains(state.field).toBuilder());
//..outgoingTrash += countGeneratedTrash(state.field));

State gravity(State state) =>
    state.rebuild((b) => b.field = fall(state.field).toBuilder());

State trash(State state) => state.rebuild((b) => b
  ..field = dropTrash(state.field, state.pendingTrash).toBuilder()
  ..pendingTrash = 0);

// should return a list of states?
State allChains(State state) {
  int chainCount = 0;
  int outgoingTrash = 0;
  State nextState = gravity(chains(state));
  while (nextState != state) {
    state = nextState;

    chainCount++;
    outgoingTrash += chainCount * 4;
    nextState = gravity(chains(state));
  }
  return state.rebuild((b) => b.outgoingTrash = outgoingTrash);
}

bool isLost(State state) =>
    isColumnFull(state.field, ((state.field.columnCount - 1) / 2).floor());

List<String> stateStrings(State state) => [
      fieldString(state.field),
      pieceString(state.currentPiece),
      pieceQueueString(state.pieceQueue),
      '${state.pendingTrash}',
      '${state.outgoingTrash}',
    ];

State stateFromStrings(List<String> stateStrings) => State((b) => b
  ..field = fieldFromString(stateStrings[0]).toBuilder()
  ..currentPiece = pieceFromString(stateStrings[1]).toBuilder()
  ..pieceQueue = pieceQueueFromString(stateStrings[2]).toBuilder()
  ..pendingTrash = int.parse(stateStrings[3])
  ..outgoingTrash = int.parse(stateStrings[4]));
