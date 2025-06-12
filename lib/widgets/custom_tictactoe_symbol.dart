import 'package:flutter/material.dart';

class CustomTicTacToeSymbol extends StatelessWidget {
  final String symbol;

  const CustomTicTacToeSymbol({required this.symbol, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(80, 80),
      painter: _SymbolPainter(symbol),
    );
  }
}

class _SymbolPainter extends CustomPainter {
  final String symbol;
  _SymbolPainter(this.symbol);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = symbol == 'X' ? Colors.purpleAccent : Colors.tealAccent;

    if (symbol == 'X') {
      canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
      canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
    } else if (symbol == 'O') {
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
