// lib/pages/victory_page.dart
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import 'game_mode_selection_page.dart';
import 'game_page.dart';

class VictoryPage extends StatefulWidget {
  final String winner;
  final GameMode gameMode;

  const VictoryPage({
    super.key,
    required this.winner,
    required this.gameMode,
  });

  @override
  State<VictoryPage> createState() => _VictoryPageState();
}

class _VictoryPageState extends State<VictoryPage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.purple.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 120),
                  const SizedBox(height: 20),
                  const Text(
                    'Félicitations !',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 10.0, color: Colors.black26)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.winner} a gagné la partie !',
                    style: const TextStyle(fontSize: 24, color: Colors.white70),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.replay),
                    label: const Text('Rejouer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade800,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      // Remplace la page de victoire par une nouvelle page de jeu
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => GamePage(mode: widget.gameMode)),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.menu),
                    label: const Text('Retour au menu'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      // Retourne à la page de sélection des modes
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const GameModeSelectionPage()),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple,
            ],
          ),
        ],
      ),
    );
  }
}