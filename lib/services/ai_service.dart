// lib/services/ai_service.dart
import 'dart:math';

enum Difficulty { easy, medium, hard }

class AIService {
  static Difficulty difficulty = Difficulty.hard;

  static int chooseMove(List<String> board) {
    return switch (difficulty) {
      Difficulty.easy => _chooseRandomMove(board),
      Difficulty.medium => _chooseMediumMove(board),
      Difficulty.hard => _chooseBestMove(board),
    };
  }

  static int _chooseRandomMove(List<String> board) {
    final emptyIndices = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') emptyIndices.add(i);
    }
    if (emptyIndices.isEmpty) return -1;
    
    final random = Random();
    return emptyIndices[random.nextInt(emptyIndices.length)];
  }

  static int _chooseMediumMove(List<String> board) {
    // 1. Vérifier si l'IA ('O') peut gagner au prochain coup
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        board[i] = 'O';
        if (_checkWinner(board) == 'O') {
          board[i] = ''; // Nettoyer le plateau
          return i;
        }
        board[i] = ''; // Nettoyer le plateau
      }
    }

    // 2. Vérifier si le joueur ('X') peut gagner au prochain coup et le bloquer
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        board[i] = 'X';
        if (_checkWinner(board) == 'X') {
          board[i] = ''; // Nettoyer le plateau
          return i;
        }
        board[i] = ''; // Nettoyer le plateau
      }
    }

    // 3. Sinon, jouer un coup aléatoire
    return _chooseRandomMove(board);
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
    // Si aucun mouvement n'améliore le score (par exemple, sur un plateau presque plein menant à une défaite),
    // jouer un coup aléatoire pour éviter de retourner -1.
    if (bestMove == -1) {
        return _chooseRandomMove(board);
    }
    return bestMove;
  }

  static int minimax(List<String> board, int depth, bool isMaximizing) {
    String? result = _checkWinner(board);
    if (result != null) {
      if (result == 'O') return 10 - depth;
      if (result == 'X') return depth - 10;
      return 0; // Égalité
    }

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == '') {
          board[i] = 'O';
          int score = minimax(board, depth + 1, false);
          board[i] = '';
          bestScore = max(score, bestScore);
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
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  static String? _checkWinner(List<String> board) {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Lignes
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonnes
      [0, 4, 8], [2, 4, 6],             // Diagonales
    ];

    for (var pattern in winPatterns) {
      final a = pattern[0], b = pattern[1], c = pattern[2];
      if (board[a] != '' && board[a] == board[b] && board[a] == board[c]) {
        return board[a];
      }
    }

    // S'il n'y a plus de cases vides et pas de gagnant, c'est une égalité
    return board.contains('') ? null : 'Égalité';
  }
}