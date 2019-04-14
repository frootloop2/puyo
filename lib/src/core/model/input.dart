import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'input.g.dart';

class Input extends EnumClass {
  static Serializer<Input> get serializer => _$inputSerializer;

  static const Input moveLeft = _$moveLeft;
  static const Input moveRight = _$moveRight;
  static const Input rotateClockwise = _$rotateClockwise;
  static const Input rotateCounterclockwise = _$rotateCounterclockwise;
  static const Input drop = _$drop;

  const Input._(String name) : super(name);

  static BuiltSet<Input> get values => _$values;

  static Input valueOf(String name) => _$valueOf(name);
}
