// pages/game_page.dart
import 'package:flutter/material.dart';
import '../models/game_mode.dart';
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
      _winningLine = <int>[];
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
      if (_board[a] != '' && _board[a] == _board[b] && _board[b] == _board[c]) {
        setState(() {
          _winner = _board[a];
          _winningLine = pattern;
        });
        return;
      }
    }

    if (!_board.contains('')) {
      setState(() => _winner = 'Draw');
    }
  }

  void _handleTap(int index) {
    if (_board[index] != '' || _winner != null) return;

    setState(() {
      _board[index] = _currentPlayer;
      _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
    });

    _checkWinner();
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: 300,
        height: 300,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: 9,
          itemBuilder: (context, index) => GestureDetector(
            onTap: () => _handleTap(index),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: _winningLine.contains(index)
                    ? Colors.lightGreenAccent.withOpacity(0.3)
                    : Colors.white,
              ),
              child: CustomTicTacToeSymbol(symbol: _board[index]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtherElements() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _winner != null
              ? (_winner == 'Draw' ? 'Match Nul' : 'Gagnant: $_winner')
              : 'Tour: $_currentPlayer',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _resetGame,
          child: const Text('Rejouer'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: SafeArea(
        child: isPortrait
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: _buildGrid(),
                  ),
                  Expanded(child: _buildOtherElements()),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGrid(),
                  Expanded(child: _buildOtherElements()),
                ],
              ),
      ),
    );
  }
}

class CustomTicTacToeSymbol extends StatelessWidget {
  final String symbol;

  const CustomTicTacToeSymbol({required this.symbol, super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: symbol == '' ? 0.0 : 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return CustomPaint(
          painter: _AnimatedSymbolPainter(symbol, value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _AnimatedSymbolPainter extends CustomPainter {
  final String symbol;
  final double progress;

  _AnimatedSymbolPainter(this.symbol, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = symbol == 'X' ? Colors.purpleAccent : Colors.teal;

    if (symbol == 'X') {
      final p = progress.clamp(0.0, 1.0);
      canvas.drawLine(
        Offset(10, 10),
        Offset(10 + (size.width - 20) * p, 10 + (size.height - 20) * p),
        paint,
      );
      canvas.drawLine(
        Offset(size.width - 10, 10),
        Offset(size.width - 10 - (size.width - 20) * p, 10 + (size.height - 20) * p),
        paint,
      );
    } else if (symbol == 'O') {
      final sweepAngle = 2 * 3.14159 * progress;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2.5),
        -3.14159 / 2,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedSymbolPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.symbol != symbol;
  }
}
