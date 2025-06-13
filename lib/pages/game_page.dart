// pages/game_page.dart
import 'package:flutter/material.dart';
import 'dart:math';

import '../models/game_mode.dart';
import '../pages/victory_page.dart';
import '../widgets/board_cell.dart';
import '../services/ai_service.dart';

class GamePage extends StatefulWidget {
  final GameMode mode;
  const GamePage({super.key, required this.mode});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  String? _winner;
  List<int> _winningLine = <int>[];

  final List<int> _movesX = [];
  final List<int> _movesO = [];
  static const int maxMovesPerPlayer = 4;

  @override
  void initState() {
    super.initState();
    if (widget.mode == GameMode.playerVsAI && _currentPlayer == 'O') {
      _playAIMove();
    }
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _currentPlayer = 'X';
      _winner = null;
      _winningLine.clear();
      _movesX.clear();
      _movesO.clear();
    });
  }

  void _checkWinner() {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      final a = pattern[0];
      if (_board[a] != '' && _board[a] == _board[pattern[1]] && _board[a] == _board[pattern[2]]) {
        final winningPlayer = _board[a];
        setState(() {
          _winner = winningPlayer;
          _winningLine = List<int>.from(pattern);
        });
        bool shouldCelebrate =
            widget.mode != GameMode.playerVsAI || (widget.mode == GameMode.playerVsAI && winningPlayer == 'X');
        if (shouldCelebrate) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => VictoryPage(winner: winningPlayer, gameMode: widget.mode),
                ),
              );
            }
          });
        }
        return;
      }
    }

    // =======================================================================
    // CORRECTION FINALE : Le match nul n'existe pas en mode Évolutif
    // =======================================================================
    if (widget.mode != GameMode.evolving && !_board.contains('')) {
      setState(() {
        _winner = 'Égalité';
        _winningLine.clear();
      });
    }
  }

  void _playMove(int index) {
    if (_board[index] != '' || _winner != null) return;

    final movingPlayer = _currentPlayer;

    setState(() {
      _board[index] = movingPlayer;
      if (widget.mode == GameMode.evolving) {
        (movingPlayer == 'X' ? _movesX : _movesO).add(index);
      }
    });

    _checkWinner();

    if (_winner == null) {
      int? oldestMoveIndexToClear;
      if (widget.mode == GameMode.evolving) {
        final playerMoves = (movingPlayer == 'X' ? _movesX : _movesO);
        if (playerMoves.length > maxMovesPerPlayer) {
          oldestMoveIndexToClear = playerMoves.removeAt(0);
        }
      }

      final nextPlayer = (movingPlayer == 'X' ? 'O' : 'X');

      setState(() {
        if (oldestMoveIndexToClear != null) {
          _board[oldestMoveIndexToClear] = '';
        }
        _currentPlayer = nextPlayer;
      });

      if (widget.mode == GameMode.playerVsAI && _currentPlayer == 'O') {
        _playAIMove();
      }
    }
  }

  void _playAIMove() async {
    if (_winner != null || widget.mode == GameMode.evolving) return;
    await Future.delayed(const Duration(milliseconds: 500));
    if (_winner == null) {
      int move = AIService.chooseMove(_board);
      if (move != -1) _playMove(move);
    }
  }

  Widget _buildBoard(double size) {
     return SizedBox(
      width: size,
      height: size,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 9,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: (_, index) => BoardCell(
            symbol: _board[index],
            onTap: () => _playMove(index),
            isWinningCell: _winningLine.contains(index),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      appBar: AppBar(
        title: Text(widget.mode == GameMode.evolving ? 'Tic Tac Toe - Évolutif' : 'Tic Tac Toe'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final boardSize = min(constraints.maxWidth, constraints.maxHeight) - 40;
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBoard(boardSize),
                    const SizedBox(height: 20),
                    Text(
                      _winner != null
                          ? (_winner == 'Égalité'
                              ? "Match nul"
                              : ((widget.mode == GameMode.playerVsAI && _winner == 'O')
                                  ? "L'IA a gagné !"
                                  : "$_winner a gagné !"))
                          : "Tour de $_currentPlayer",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _resetGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Rejouer', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}