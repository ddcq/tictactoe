// widgets/board_cell.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';

class BoardCell extends StatelessWidget {
  final String symbol;
  final VoidCallback onTap;
  final bool showConfetti;

  const BoardCell({
    super.key,
    required this.symbol,
    required this.onTap,
    this.showConfetti = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color symbolColor = symbol == 'X'
        ? Colors.blue.shade700
        : symbol == 'O'
            ? Colors.red.shade600
            : Colors.transparent;

    final confettiController = ConfettiController(duration: const Duration(seconds: 1));
    if (showConfetti) {
      confettiController.play();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            constraints: const BoxConstraints(minWidth: 64, minHeight: 64),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: Colors.black26, width: 1),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: Text(
                  symbol,
                  key: ValueKey<String>(symbol),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: symbolColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (showConfetti)
          ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.6,
            numberOfParticles: 10,
            gravity: 0.3,
          ),
      ],
    );
  }
}