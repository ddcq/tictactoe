// lib/components/game_board.dart
import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../components/board_painter.dart';

class GameBoard extends StatelessWidget {
  final List<String> board;
  final List<int> winningLine;
  final int? disappearingIndex;
  final Function(int) onCellTap;
  final double boardSize;
  // Ajout du gameMode pour pouvoir différencier la logique de tap
  final GameMode gameMode; // Nouvelle propriété

  const GameBoard({
    super.key,
    required this.board,
    required this.winningLine,
    required this.disappearingIndex,
    required this.onCellTap,
    required this.boardSize,
    required this.gameMode, // Nouvelle propriété
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: BoardPainter()),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (_, index) {
              final symbol = board[index];
              final isWinning = winningLine.contains(index);
              final bool isDisappearing = disappearingIndex == index;

              // Modifier la condition onTap
              // Le tap est permis si la case est vide OU si c'est le mode évolutif et que c'est la case qui va disparaître
              final bool canTap = board[index].isEmpty || (gameMode == GameMode.evolving && isDisappearing);

              return GestureDetector(
                onTap: canTap ? () => onCellTap(index) : null, // Déclenche onTap seulement si canTap est vrai
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: isDisappearing ? 0.5 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: AnimatedScale(
                      scale: isDisappearing ? 0.8 : (symbol.isEmpty ? 0 : 1),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      child: Text(
                        symbol,
                        style: TextStyle(
                          fontSize: boardSize / 5,
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}