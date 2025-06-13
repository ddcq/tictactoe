// pages/game_page.dart
import 'package:flutter/material.dart';
import 'dart:math';

import '../models/game_mode.dart';
import '../pages/victory_page.dart';
import '../widgets/board_cell.dart';
import '../services/ai_service.dart';

class BoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.shade300
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Lignes verticales
    canvas.drawLine(Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(size.width * 2 / 3, 0), Offset(size.width * 2 / 3, size.height), paint);

    // Lignes horizontales
    canvas.drawLine(Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, size.height * 2 / 3), Offset(size.width, size.height * 2 / 3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: BoardPainter(),
          ),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (_, index) {
              final symbol = _board[index];
              final isWinning = _winningLine.contains(index);

              // ==========================================================
              // CORRECTION
              // ==========================================================
              return GestureDetector(
                onTap: () => _playMove(index),
                // CETTE LIGNE EST LA CORRECTION : Elle rend la zone cliquable
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: AnimatedScale(
                    scale: symbol.isEmpty ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: Text(
                      symbol,
                      style: TextStyle(
                        fontSize: size / 5,
                        fontWeight: FontWeight.bold,
                        color: symbol == 'X' 
                          ? const Color(0xFFFFC107)
                          : const Color(0xFFE0F7FA),
                        shadows: [
                          if (isWinning)
                            const Shadow(
                              blurRadius: 20.0,
                              color: Colors.white,
                              offset: Offset(0, 0),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              // ==========================================================
              // FIN DE LA CORRECTION
              // ==========================================================
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser la police fraîchement importée pour le titre
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // Fini le fond uni, place à un dégradé subtil
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A6C9B), // Un bleu profond
              Color(0xFF2E4C6D), // Un bleu encore plus sombre
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Barre de titre personnalisée
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.mode == GameMode.evolving ? 'Mode Évolutif' : 'Tic Tac Toe',
                  style: textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),

              // Le plateau de jeu
              LayoutBuilder(
                builder: (context, constraints) {
                  final boardSize = min(constraints.maxWidth, constraints.maxHeight) * 0.8;
                  return _buildBoard(boardSize);
                },
              ),
              
              // Zone de statut et bouton
              _buildStatusAndReset(context),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget pour la zone inférieure (statut + bouton)
  Widget _buildStatusAndReset(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    String statusText;

    if (_winner != null) {
      if (_winner == 'Égalité') {
        statusText = "Match nul";
      } else if (widget.mode == GameMode.playerVsAI && _winner == 'O') {
        statusText = "L'IA a gagné !";
      } else {
        statusText = "$_winner a gagné !";
      }
    } else {
      statusText = "Tour de $_currentPlayer";
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            statusText,
            style: textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 24),
          // Bouton rejouer avec un style plus moderne
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Rejouer'),
            onPressed: _resetGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: const Color(0xFF2E4C6D),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}