// lib/components/game_status_and_actions.dart
import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../pages/game_mode_selection_page.dart';

class GameStatusAndActions extends StatelessWidget {
  final String? winner;
  final String currentPlayer;
  final GameMode gameMode;
  final VoidCallback onResetGame;
  final bool isGameStarted;
  final VoidCallback onAIBegin;

  const GameStatusAndActions({
    super.key,
    required this.winner,
    required this.currentPlayer,
    required this.gameMode,
    required this.onResetGame,
    required this.isGameStarted,
    required this.onAIBegin,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    String statusText;

    if (winner != null) {
      if (winner == 'Égalité') {
        statusText = "Match nul ! Dommage...";
      } else if (gameMode == GameMode.playerVsAI && winner == 'O') {
        statusText = "L'IA a gagné ! Mieux la prochaine fois.";
      } else {
        statusText = "Félicitations au joueur $winner !";
      }
    } else {
      // Nouvelle logique ici
      if (gameMode == GameMode.playerVsAI && currentPlayer == 'O') {
        statusText = "À l'IA de jouer maintenant."; // Message spécifique pour l'IA
      } else {
        statusText = "À vous de jouer, joueur $currentPlayer !"; // Message pour les joueurs humains
      }
    }

    String mainButtonText;
    IconData mainButtonIcon;
    VoidCallback mainButtonAction;

    if (gameMode == GameMode.playerVsAI && !isGameStarted && winner == null) {
      mainButtonText = "Laisser l'IA commencer";
      mainButtonIcon = Icons.computer;
      mainButtonAction = onAIBegin;
    } else {
      mainButtonText = "Rejouer";
      mainButtonIcon = Icons.refresh;
      mainButtonAction = onResetGame;
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            statusText,
            style: textTheme.headlineSmall?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(mainButtonIcon),
            label: Text(mainButtonText),
            onPressed: mainButtonAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: const Color(0xFF2E4C6D),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.menu),
            label: const Text('Retour au menu'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const GameModeSelectionPage(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}