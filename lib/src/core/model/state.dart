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

State moveRight(State state) => state.rebuild((b) => b.currentPiece =
    movePieceRight(state.currentPiece, state.field.columnCount).toBuilder());

State moveLeft(State state) => state.rebuild(
    (b) => b.currentPiece = movePieceLeft(state.currentPiece).toBuilder());

State rotateClockwise(State state) => state.rebuild((b) => b.currentPiece =
    rotatePieceClockwise(state.currentPiece, state.field.columnCount)
        .toBuilder());

State rotateCounterclockwise(State state) =>
    state.rebuild((b) => b.currentPiece =
        rotatePieceCounterclockwise(state.currentPiece, state.field.columnCount)
            .toBuilder());

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
