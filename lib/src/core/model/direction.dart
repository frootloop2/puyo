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
