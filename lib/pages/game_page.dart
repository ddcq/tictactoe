import 'package:flutter/material.dart';
import 'dart:math'; // NOUVEAU : Pour utiliser la fonction min()

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

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _currentPlayer = 'X';
      _winner = null;
      _winningLine.clear();
    });
  }

  void _checkWinner() {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      final a = pattern[0], b = pattern[1], c = pattern[2];
      if (_board[a] != '' && _board[a] == _board[b] && _board[a] == _board[c]) {
        final winningPlayer = _board[a];

        setState(() {
          _winner = winningPlayer;
          _winningLine = List<int>.from(pattern);
        });

        bool shouldCelebrate =
            widget.mode == GameMode.playerVsPlayer ||
            (widget.mode == GameMode.playerVsAI && winningPlayer == 'X');

        if (shouldCelebrate) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      VictoryPage(winner: winningPlayer, gameMode: widget.mode),
                ),
              );
            }
          });
        }
        return;
      }
    }

    if (!_board.contains('')) {
      setState(() {
        _winner = 'Égalité';
        _winningLine.clear();
      });
    }
  }

  void _playMove(int index) {
    if (_board[index] != '' || _winner != null) return;

    setState(() => _board[index] = _currentPlayer);
    _checkWinner();

    if (_winner == null) {
      setState(() => _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X');
      if (widget.mode == GameMode.playerVsAI && _currentPlayer == 'O') {
        _playAIMove();
      }
    }
  }

  void _playAIMove() async {
    if (_winner != null) return;
    await Future.delayed(const Duration(milliseconds: 500));
    if (_winner == null) {
      int move = AIService.chooseMove(_board);
      if (move != -1) _playMove(move);
    }
  }

  // MODIFIÉ : La méthode prend maintenant la taille en argument
  Widget _buildBoard(double size) {
    // MODIFIÉ : On utilise un SizedBox pour contraindre la taille de la grille
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
  void initState() {
    super.initState();
    if (widget.mode == GameMode.playerVsAI && _currentPlayer == 'O') {
      _playAIMove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        backgroundColor: Colors.blue.shade700,
      ),
      // NOUVEAU : On utilise LayoutBuilder pour obtenir les contraintes de l'espace parent
      body: LayoutBuilder(
        builder: (context, constraints) {
          // On calcule la taille de la grille. Ce sera la plus petite dimension
          // (largeur ou hauteur) de l'espace disponible, moins un peu de marge.
          final boardSize = min(constraints.maxWidth, constraints.maxHeight - 140) - 40;

          // NOUVEAU : On enveloppe la Column dans un SingleChildScrollView
          // pour éviter tout dépassement sur les écrans très petits/étroits.
          return SingleChildScrollView(
            child: ConstrainedBox(
              // Assure que la zone scrollable prend au moins la hauteur de l'écran
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // MODIFIÉ : On passe la taille calculée à la méthode _buildBoard
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