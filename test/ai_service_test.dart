// test/ai_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/services/ai_service.dart';

void main() {
  group('AIService', () {
    test('chooses first available cell', () {
      final board = ['X', '', '', 'O', '', '', '', '', ''];
      final move = AIService.chooseMove(board);
      expect(move, 1);
    });

    test('returns -1 when board is full', () {
      final board = ['X', 'O', 'X', 'X', 'O', 'X', 'O', 'X', 'O'];
      final move = AIService.chooseMove(board);
      expect(move, -1);
    });
  });
}
