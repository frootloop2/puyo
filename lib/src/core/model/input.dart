import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'input.g.dart';

class InputType extends EnumClass {
  static Serializer<InputType> get serializer => _$inputTypeSerializer;

  static const InputType moveLeft = _$moveLeft;
  static const InputType moveRight = _$moveRight;
  static const InputType rotateClockwise = _$rotateClockwise;
  static const InputType rotateCounterclockwise = _$rotateCounterclockwise;
  static const InputType drop = _$drop;

  const InputType._(String name) : super(name);

  static BuiltSet<InputType> get values => _$values;

  static InputType valueOf(String name) => _$valueOf(name);
}

abstract class Input implements Built<Input, InputBuilder> {
  static Serializer<Input> get serializer => _$inputSerializer;

  int get playerId;

  InputType get inputType;

  Input._();

  factory Input([updates(InputBuilder b)]) = _$Input;
}
