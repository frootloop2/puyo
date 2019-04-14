import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:puyo/src/core/model/state.dart';

part 'game.g.dart';

abstract class Game implements Built<Game, GameBuilder> {
  static Serializer<Game> get serializer => _$gameSerializer;

  BuiltList<State> get states;

  Game._();

  factory Game([updates(GameBuilder b)]) = _$Game;
}
