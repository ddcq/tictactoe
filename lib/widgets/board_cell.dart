// widgets/board_cell.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';

// Assurez-vous que votre BoardCell accepte 'isWinningCell'
// Voici un exemple pour `board_cell.dart` si vous devez le modifier
class BoardCell extends StatefulWidget {
  final String symbol;
  final VoidCallback onTap;
  final bool isWinningCell;

  const BoardCell({
    Key? key,
    required this.symbol,
    required this.onTap,
    this.isWinningCell = false,
  }) : super(key: key);

  @override
  State<BoardCell> createState() => _BoardCellState();
}

class _BoardCellState extends State<BoardCell> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Se déclenche quand le joueur appuie sur la case
      onTapDown: (_) {
        if (widget.symbol == '') {
          setState(() => _isTapped = true);
        }
      },
      // Se déclenche quand le joueur relâche la case
      onTapUp: (_) {
        if (widget.symbol == '') {
          setState(() => _isTapped = false);
        }
      },
      // Se déclenche si le geste est annulé (ex: doigt qui glisse hors de la case)
      onTapCancel: () {
        if (widget.symbol == '') {
          setState(() => _isTapped = false);
        }
      },
      // Exécute la logique du jeu
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        // Applique une transformation (échelle) si la case est pressée
        transform: Matrix4.identity()..scale(_isTapped ? 0.9 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade100, width: 2),
          color: widget.isWinningCell ? Colors.green.shade200 : null,
        ),
        child: Center(
          child: Text(
            widget.symbol,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: widget.symbol == 'X' ? Colors.blue.shade800 : Colors.red.shade600,
            ),
          ),
        ),
      ),
    );
  }
}
