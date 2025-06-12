// pages/game_page.dart
import 'package:flutter/material.dart';
import '../models/game_mode.dart';
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
        setState(() {
          _winner = _board[a];
          _winningLine = List<int>.from(pattern);
        });
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
    await Future.delayed(const Duration(milliseconds: 500));
    int move = AIService.chooseMove(_board);
    if (move != -1) _playMove(move);
  }

  Widget _buildBoard() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: GridView.builder(
          itemCount: 9,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: (_, index) => BoardCell(
            symbol: _board[index],
            onTap: () => _playMove(index),
            showConfetti: _winningLine.contains(index),
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
                ? (_winner == 'Égalité' ? "Match nul" : "$_winner a gagné !")
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
