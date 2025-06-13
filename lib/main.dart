import 'package:flutter/material.dart';
import 'pages/game_mode_selection_page.dart';
// dans main.dart
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const TicTacToeApp());

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Appliquer la police sur tout le thème texte de l'application
        textTheme: GoogleFonts.patrickHandTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: GameModeSelectionPage(),
    );
  }
}
