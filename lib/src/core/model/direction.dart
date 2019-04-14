import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direction.g.dart';

class Direction extends EnumClass {
  static Serializer<Direction> get serializer => _$directionSerializer;

  static const Direction up = _$up;
  static const Direction right = _$right;
  static const Direction down = _$down;
  static const Direction left = _$left;

  const Direction._(String name) : super(name);

  static BuiltSet<Direction> get values => _$values;

  static Direction valueOf(String name) => _$valueOf(name);
}

const Map<Direction, String> characterByDirection = {
  Direction.up: 'U',
  Direction.right: 'R',
  Direction.down: 'D',
  Direction.left: 'L',
};

const Map<String, Direction> directionByCharacter = {
  'U': Direction.up,
  'R': Direction.right,
  'D': Direction.down,
  'L': Direction.left,
};
