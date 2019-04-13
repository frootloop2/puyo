enum Color {
  red,
  green,
  blue,
  yellow,
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
