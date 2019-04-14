import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:puyo/src/core/model/color.dart';
import 'package:puyo/src/core/model/direction.dart';
import 'package:puyo/src/core/model/field.dart';
import 'package:puyo/src/core/model/game.dart';
import 'package:puyo/src/core/model/input.dart';
import 'package:puyo/src/core/model/piece.dart';
import 'package:puyo/src/core/model/piece_queue.dart';
import 'package:puyo/src/core/model/state.dart';

part 'serializers.g.dart';

@SerializersFor([
  Color,
  Cell,
  Direction,
  Field,
  Game,
  Input,
  InputType,
  Piece,
  PieceQueue,
  State,
  Value,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Cell)]),
          () => new ListBuilder<Cell>()))
    .build();
