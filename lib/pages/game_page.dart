// pages/game_page.dart

import 'package:flutter/material.dart';
import 'dart:math';

import '../models/game_mode.dart';
import '../pages/victory_page.dart';
import '../services/ai_service.dart';
import '../pages/game_mode_selection_page.dart';
import '../components/game_board.dart';
import '../components/game_status_and_actions.dart';
import '../models/game_controller.dart';
import 'package:provider/provider.dart';
import '../components/board_painter.dart';

class GamePage extends StatefulWidget {
  final GameMode mode;
  const GamePage({super.key, required this.mode});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameController(widget.mode),
      child: Consumer<GameController>(
        builder: (context, gameController, child) {
          if (gameController.victoryDetected) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // *** NOUVELLE LOGIQUE POUR shouldNavigateToVictory ***
              bool shouldNavigateToVictory = false;

              if (gameController.winner != null) {
                if (gameController.winner == 'X') {
                  shouldNavigateToVictory = true; // X gagne toujours
                } else if (gameController.winner == 'O') {
                  // O gagne : vérifier le mode de jeu
                  // Si c'est Player vs Player (mode Duo)
                  // OU si c'est le mode Évolutif (où O est aussi un humain)
                  if (gameController.gameMode == GameMode.playerVsPlayer ||
                      gameController.gameMode == GameMode.evolving) {
                    shouldNavigateToVictory = true;
                  }
                  // En mode PlayerVsAI, si O gagne, ce n'est pas une victoire humaine,
                  // donc shouldNavigateToVictory reste false (ce qui est le comportement voulu).
                }
                // Si winner est 'Égalité', shouldNavigateToVictory reste false (comportement voulu).
              }
              // ******************************************************


              if (shouldNavigateToVictory) {
                if (mounted) {
                  gameController.markVictoryHandled();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VictoryPage(
                        winner: gameController.winner!,
                        gameMode: gameController.gameMode,
                      ),
                    ),
                  );
                }
              }
            });
          }

          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4A6C9B),
                    Color(0xFF2E4C6D),
                  ],
                ),
              ),
              child: SafeArea(
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    if (orientation == Orientation.landscape) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final boardSize =
                                  min(constraints.maxWidth, constraints.maxHeight) *
                                      0.8;
                              return GameBoard(
                                board: gameController.board,
                                winningLine: gameController.winningLine,
                                disappearingIndex: gameController.disappearingIndex,
                                onCellTap: gameController.playMove,
                                boardSize: boardSize,
                                gameMode: gameController.gameMode,
                              );
                            },
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GameStatusAndActions(
                                winner: gameController.winner,
                                currentPlayer: gameController.currentPlayer,
                                gameMode: gameController.gameMode,
                                onResetGame: gameController.resetGame,
                                isGameStarted: gameController.isGameStarted,
                                onAIBegin: gameController.letAIBegin,
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final boardSize =
                                  min(constraints.maxWidth, constraints.maxHeight) *
                                      0.8;
                              return GameBoard(
                                board: gameController.board,
                                winningLine: gameController.winningLine,
                                disappearingIndex: gameController.disappearingIndex,
                                onCellTap: gameController.playMove,
                                boardSize: boardSize,
                                gameMode: gameController.gameMode,
                              );
                            },
                          ),
                          GameStatusAndActions(
                            winner: gameController.winner,
                            currentPlayer: gameController.currentPlayer,
                            gameMode: gameController.gameMode,
                            onResetGame: gameController.resetGame,
                            isGameStarted: gameController.isGameStarted,
                            onAIBegin: gameController.letAIBegin,
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
