// lib/models/game_controller.dart
import 'package:flutter/material.dart';
import './game_mode.dart';
import '../services/ai_service.dart';

class GameController extends ChangeNotifier {
  List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  String? _winner;
  List<int> _winningLine = <int>[];
  final GameMode _gameMode;

  final List<int> _movesX = [];
  final List<int> _movesO = [];
  static const int maxMovesPerPlayer = 3;
  int? _disappearingIndex;

  bool _victoryDetected = false;
  bool _isGameStarted = false;

  GameController(this._gameMode) {
    _updateDisappearingIndex();
  }

  // Getters
  List<String> get board => _board;
  String get currentPlayer => _currentPlayer;
  String? get winner => _winner;
  List<int> get winningLine => _winningLine;
  int? get disappearingIndex => _disappearingIndex;
  GameMode get gameMode => _gameMode;
  bool get victoryDetected => _victoryDetected;
  bool get isGameStarted => _isGameStarted;

  void resetGame() {
    _board = List.filled(9, '');
    _currentPlayer = 'X';
    _winner = null;
    _winningLine.clear();
    _movesX.clear();
    _movesO.clear();
    _disappearingIndex = null;
    _victoryDetected = false;
    _isGameStarted = false;
    _updateDisappearingIndex();
    notifyListeners();
  }

  void _checkWinner() {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var pattern in winPatterns) {
      final a = pattern[0];
      if (_board[a] != '' &&
          _board[a] == _board[pattern[1]] &&
          _board[a] == _board[pattern[2]]) {
        _winner = _board[a];
        _winningLine = List<int>.from(pattern);
        _victoryDetected = true;
        return;
      }
    }

    if (_gameMode != GameMode.evolving && !_board.contains('')) {
      _winner = 'Égalité';
      _winningLine.clear();
      _victoryDetected = true;
    }
  }

  Future<void> playMove(int index) async {
    // CONDITION DE JEU MODIFIÉE POUR LE MODE ÉVOLUTIF
    // Si c'est le mode évolutif et que la case est l'index disparaissant,
    // on permet le coup même si la case n'est pas vide.
    if (_board[index] != '' && index != _disappearingIndex && _gameMode == GameMode.evolving ||
        _board[index] != '' && _gameMode != GameMode.evolving || // Condition originale pour les autres modes
        _winner != null) {
      return;
    }

    // Marquer la partie comme commencée dès le premier coup
    if (!_isGameStarted) {
      _isGameStarted = true;
    }

    final movingPlayer = _currentPlayer;
    final currentPlayerMoves = (movingPlayer == 'X' ? _movesX : _movesO);

    // Gérer la disparition du pion si le joueur atteint la limite
    int? oldestMoveIndexToClear;
    if (_gameMode == GameMode.evolving) {
      // Si la case cliquée est l'ancienne case menacée de disparition
      if (index == _disappearingIndex && currentPlayerMoves.length >= maxMovesPerPlayer) {
        // La case qui aurait dû disparaître est celle sur laquelle le joueur joue.
        // On la retire de la liste des mouvements pour ne pas qu'elle soit effacée plus tard.
        currentPlayerMoves.remove(index);
      } else if (currentPlayerMoves.length >= maxMovesPerPlayer) {
        // Si le joueur a déjà le nombre max de pions et joue sur une AUTRE case
        oldestMoveIndexToClear = currentPlayerMoves.removeAt(0);
      }
    }

    // Effacer l'ancien pion si nécessaire
    if (oldestMoveIndexToClear != null) {
      _board[oldestMoveIndexToClear] = '';
    }

    // Placer le nouveau pion
    _board[index] = movingPlayer;
    if (_gameMode == GameMode.evolving) {
      currentPlayerMoves.add(index);
    }
    notifyListeners();

    _checkWinner();

    if (_winner == null) {
      final nextPlayer = (movingPlayer == 'X' ? 'O' : 'X');
      _currentPlayer = nextPlayer;
      _updateDisappearingIndex(); // Mettre à jour l'index après le changement de joueur
      notifyListeners();

      if (_gameMode == GameMode.playerVsAI && _currentPlayer == 'O') {
        await _playAIMove();
      }
    } else {
      _updateDisappearingIndex(); // Important pour que la ligne gagnante s'affiche correctement
      notifyListeners();
    }
  }

  Future<void> letAIBegin() async {
    if (_gameMode == GameMode.playerVsAI && !_isGameStarted && _currentPlayer == 'X') {
      _isGameStarted = true;
      _currentPlayer = 'O';
      notifyListeners();
      await _playAIMove();
    }
  }

  Future<void> _playAIMove() async {
    if (_winner != null || _gameMode == GameMode.evolving) return; // L'IA ne joue pas en mode évolutif ici
    await Future.delayed(const Duration(milliseconds: 500));
    if (_winner == null) {
      int move = AIService.chooseMove(_board);
      if (move != -1) await playMove(move);
    }
  }

  void _updateDisappearingIndex() {
    if (_gameMode == GameMode.evolving && _winner == null) {
      final playerMoves = (_currentPlayer == 'X') ? _movesX : _movesO;
      if (playerMoves.length >= maxMovesPerPlayer) {
        _disappearingIndex = playerMoves.first;
        return;
      }
    }
    _disappearingIndex = null;
  }

  void markVictoryHandled() {
    _victoryDetected = false;
  }
}