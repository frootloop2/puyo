enum Color {
  red,
  green,
  blue,
  yellow,
}
enum Direction {
  up,
  right,
  down,
  left,
}

const Map<Color, String> characterByColor = {
  Color.red: 'R',
  Color.green: 'G',
  Color.blue: 'B',
  Color.yellow: 'Y',
};

const Map<Direction, String> characterByDirection = {
  Direction.up: 'U',
  Direction.right: 'R',
  Direction.down: 'D',
  Direction.left: 'L',
};
