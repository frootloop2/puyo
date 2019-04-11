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

enum Direction {
  up,
  right,
  down,
  left,
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
