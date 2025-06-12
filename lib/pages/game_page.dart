// pages/game_page.dart
import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../pages/victory_page.dart'; // Importer la nouvelle page
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
        
        // On met à jour l'état pour afficher la ligne gagnante
        setState(() {
          _winner = winningPlayer;
          _winningLine = List<int>.from(pattern);
        });

        // Condition pour naviguer vers la page de victoire
        bool shouldCelebrate = 
            widget.mode == GameMode.playerVsPlayer || // Toujours en Pvp
            (widget.mode == GameMode.playerVsAI && winningPlayer == 'X'); // Seulement si le joueur gagne contre l'IA

        if (shouldCelebrate) {
          // Délai pour que le joueur voie la ligne gagnante
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) { // Vérifier que le widget est toujours "monté"
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => VictoryPage(
                    winner: winningPlayer,
                    gameMode: widget.mode,
                  ),
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
    // Ne pas jouer si une navigation est déjà en cours ou si la partie est gagnée
    if (_winner != null) return;
    await Future.delayed(const Duration(milliseconds: 500));
    if (_winner == null) { // Double vérification
      int move = AIService.chooseMove(_board);
      if (move != -1) _playMove(move);
    }
  }

  Widget _buildBoard() {
    return AspectRatio(
      aspectRatio: 1,
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
          physics: const NeverScrollableScrollPhysics(), // Empêcher le scroll
          itemCount: 9,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: (_, index) => BoardCell(
            symbol: _board[index],
            onTap: () => _playMove(index),
            isWinningCell: _winningLine.contains(index), // Modifié pour correspondre à BoardCell
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBoard(),
          const SizedBox(height: 20),
          Text(
            _winner != null
                ? (_winner == 'Égalité' ? "Match nul" : (
                  (widget.mode == GameMode.playerVsAI && _winner == 'O') 
                    ? "L'IA a gagné !" 
                    : "$_winner a gagné !"
                  ))
                : "Tour de $_currentPlayer",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Rejouer', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}

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
