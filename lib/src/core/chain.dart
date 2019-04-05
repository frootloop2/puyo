import 'package:built_collection/built_collection.dart';
import 'package:puyo/src/core/model/field.dart';

const minimumChainLength = 4;

// TODO: make faster

BuiltSet<Cell> chainsInField(Field field) => BuiltSet(field.cells
    .where((cell) => cell.isNotEmpty)
    .where((cell) => _isPopped(field, cell)));

bool _isPopped(Field field, Cell cell) =>
    _findChainLength(field, cell) >= minimumChainLength;

int _findChainLength(Field field, Cell cell) {
  final Set<Cell> chain = {};
  _populateChain(field, cell, chain);
  return chain.length;
}

void _populateChain(Field field, Cell cell, Set<Cell> chain) {
  chain.add(cell);
  neighbors(field, cell)
      .where((neighbor) => cell.value == neighbor.value)
      .where((neighbor) => !chain.contains(neighbor))
      .forEach((neighbor) => _populateChain(field, neighbor, chain));
}
