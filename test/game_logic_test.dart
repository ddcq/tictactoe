// test/game_logic_test.dart
import 'package:flutter_test/flutter_test.dart';

bool hasWinner(List<String> board, String player) {
  const winPatterns = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [0, 3, 6], [1, 4, 7], [2, 5, 8],
    [0, 4, 8], [2, 4, 6],
  ];

  for (var pattern in winPatterns) {
    if (pattern.every((i) => board[i] == player)) return true;
  }
  return false;
}

void main() {
  group('Game Logic - Victory Detection', () {
    test('detects horizontal win', () {
      final board = ['X', 'X', 'X', '', '', '', '', '', ''];
      expect(hasWinner(board, 'X'), true);
    });

    test('detects vertical win', () {
      final board = ['O', '', '', 'O', '', '', 'O', '', ''];
      expect(hasWinner(board, 'O'), true);
    });

    test('detects diagonal win', () {
      final board = ['X', '', '', '', 'X', '', '', '', 'X'];
      expect(hasWinner(board, 'X'), true);
    });

    test('detects no winner', () {
      final board = ['X', 'O', 'X', 'X', 'O', 'O', 'O', 'X', 'X'];
      expect(hasWinner(board, 'X'), false);
    });
  });
}
