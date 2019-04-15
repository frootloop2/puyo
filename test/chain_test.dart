import 'package:puyo/src/core/chain.dart';
import 'package:puyo/src/core/model/field.dart';
import 'package:test/test.dart';

void main() {
  test('identifies chains', () {
    final Field field = fieldFromString('EEEE\n'
        'GRRG\n'
        'ERRG\n'
        'RGGG\n'
        'BBBG');

    expect(
        poppedCellsInField(field),
        unorderedEquals([
          // group of 6 greens
          field.cellsByRowByColumn[1][1],
          field.cellsByRowByColumn[2][1],
          field.cellsByRowByColumn[3][0],
          field.cellsByRowByColumn[3][1],
          field.cellsByRowByColumn[3][2],
          field.cellsByRowByColumn[3][3],
          // group of 4 reds
          field.cellsByRowByColumn[1][2],
          field.cellsByRowByColumn[2][2],
          field.cellsByRowByColumn[1][3],
          field.cellsByRowByColumn[2][3],
          // missing:
          // - unconnected red   [0][1]
          // - unconnected green [0][3]
          // - group of 3 blues  [0][0], [1][0], [2][0]
          // - empty cells       [0][2], [0][4], [1][4], [2][4], [3][4]
        ]));
  });

  test('identifies trash next to chains', () {
    final Field field = fieldFromString('TGTT\nTRRT\nTRRT\nTTTT');
    expect(
        poppedCellsInField(field),
        unorderedEquals([
          // group of 4 reds
          field.cellsByRowByColumn[1][1],
          field.cellsByRowByColumn[1][2],
          field.cellsByRowByColumn[2][1],
          field.cellsByRowByColumn[2][2],
          // adjacent 7 trash
          field.cellsByRowByColumn[0][1],
          field.cellsByRowByColumn[0][2],
          field.cellsByRowByColumn[1][0],
          field.cellsByRowByColumn[2][0],
          field.cellsByRowByColumn[2][3],
          field.cellsByRowByColumn[3][1],
          field.cellsByRowByColumn[3][2],
          // missing:
          // - adjacent green [1][3]
          // - unadjacent trash [0][0], [0][3], [3][0], [3][3]
        ]));
  });

  test('does not count chains of trash', () {
    final Field field = fieldFromString('EEEE\nTTTT');
    expect(poppedCellsInField(field), isEmpty);
  });
}
