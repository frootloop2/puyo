import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'color.g.dart';

class Color extends EnumClass {
  static Serializer<Color> get serializer => _$colorSerializer;

  static const Color red = _$red;
  static const Color green = _$green;
  static const Color blue = _$blue;
  static const Color yellow = _$yellow;

  const Color._(String name) : super(name);

  static BuiltSet<Color> get values => _$values;

  static Color valueOf(String name) => _$valueOf(name);
}

const Map<Color, String> characterByColor = {
  Color.red: 'R',
  Color.green: 'G',
  Color.blue: 'B',
  Color.yellow: 'Y',
};

const Map<String, Color> colorByCharacter = {
  'R': Color.red,
  'G': Color.green,
  'B': Color.blue,
  'Y': Color.yellow,
};
