// lib/services/ai_service.dart
enum Difficulty { easy, hard }

class AIService {
  static Difficulty difficulty = Difficulty.hard;

  static int chooseMove(List<String> board) {
    return switch (difficulty) {
      Difficulty.easy => _chooseRandomMove(board),
      Difficulty.hard => _chooseBestMove(board),
    };
  }

  static int _chooseRandomMove(List<String> board) {
    final emptyIndices = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') emptyIndices.add(i);
    }
    emptyIndices.shuffle();
    return emptyIndices.isNotEmpty ? emptyIndices.first : -1;
  }

  static int _chooseBestMove(List<String> board) {
    int bestScore = -1000;
    int bestMove = -1;

    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        board[i] = 'O';
        int score = minimax(board, 0, false);
        board[i] = '';
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }
    return bestMove;
  }

  static int minimax(List<String> board, int depth, bool isMaximizing) {
    String? result = _checkWinner(board);
    if (result != null) {
      if (result == 'O') return 10 - depth;
      if (result == 'X') return depth - 10;
      return 0;
    }

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == '') {
          board[i] = 'O';
          int score = minimax(board, depth + 1, false);
          board[i] = '';
          bestScore = score > bestScore ? score : bestScore;
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == '') {
          board[i] = 'X';
          int score = minimax(board, depth + 1, true);
          board[i] = '';
          bestScore = score < bestScore ? score : bestScore;
        }
      }
      return bestScore;
    }
  }

  static String? _checkWinner(List<String> board) {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      final a = pattern[0], b = pattern[1], c = pattern[2];
      if (board[a] != '' && board[a] == board[b] && board[a] == board[c]) {
        return board[a];
      }
    }

    return board.contains('') ? null : 'Égalité';
  }
}
