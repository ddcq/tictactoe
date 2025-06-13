// pages/game_mode_selection_page.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_mode.dart';
import '../services/ai_service.dart';
import 'game_page.dart';

class GameModeSelectionPage extends StatefulWidget {
  const GameModeSelectionPage({super.key});

  @override
  State<GameModeSelectionPage> createState() => _GameModeSelectionPageState();
}

class _GameModeSelectionPageState extends State<GameModeSelectionPage> {
  final PageController _pageController = PageController(viewportFraction: 0.35);
  int _currentIndex = 0;
  final FocusNode _focusNode = FocusNode();

  // MODIFIÉ : Ajout du nouveau mode de jeu dans la liste
  final List<_GameModeCard> _cards = [
    _GameModeCard(
      label: 'Solo - Facile',
      mode: GameMode.playerVsAI,
      difficulty: Difficulty.easy,
    ),
    _GameModeCard(
      label: 'Solo - Intermédiaire',
      mode: GameMode.playerVsAI,
      difficulty: Difficulty.medium,
    ),
    _GameModeCard(
      label: 'Solo - Difficile',
      mode: GameMode.playerVsAI,
      difficulty: Difficulty.hard,
    ),
    _GameModeCard(label: 'Deux joueurs', mode: GameMode.playerVsPlayer),
    _GameModeCard(label: 'Mode Évolutif', mode: GameMode.evolving),
    _GameModeCard(label: 'En ligne', mode: null, disabled: true),
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onCardTap(_GameModeCard card) {
    if (card.disabled || card.mode == null) return;
    // La difficulté n'est pertinente que pour le mode Joueur vs IA
    if (card.mode == GameMode.playerVsAI && card.difficulty != null) {
      AIService.difficulty = card.difficulty!;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GamePage(mode: card.mode!)),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (_currentIndex > 0) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (_currentIndex < _cards.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        _onCardTap(_cards[_currentIndex]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: constraints.maxHeight * 0.7,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentIndex = index),
                    itemCount: _cards.length,
                    scrollBehavior: const ScrollBehavior().copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                      },
                    ),
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      final isActive = index == _currentIndex;
                      final double scale = isActive ? 1.3 : 1.0;

                      final double cardWidth = constraints.maxWidth * _pageController.viewportFraction;
                      final double widthIncrease = cardWidth * 0.3;
                      final double marginForNeighbor = widthIncrease / 2;

                      EdgeInsets margin = const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 20,
                      );

                      if (index == _currentIndex - 1) {
                        margin = margin.copyWith(right: margin.right + marginForNeighbor);
                      }

                      if (index == _currentIndex + 1) {
                        margin = margin.copyWith(left: margin.left + marginForNeighbor);
                      }

                      return GestureDetector(
                        onTap: () => _onCardTap(card),
                        child: AnimatedContainer(
                          margin: margin,
                          transform: Matrix4.identity()..scale(scale),
                          transformAlignment: Alignment.center,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              // Le nom du fichier image est généré dynamiquement à partir du label
                              image: AssetImage(
                                'assets/images/bg_${card.label.toLowerCase().replaceAll(' ', '_').replaceAll('-', '').replaceAll('é', 'e')}.jpg',
                              ),
                              fit: BoxFit.cover,
                              colorFilter: card.disabled
                                  ? const ColorFilter.mode(
                                      Colors.grey,
                                      BlendMode.saturation,
                                    )
                                  : null,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              if (isActive)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 8),
                                  blurRadius: 12,
                                ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  card.label,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: isActive ? 20 : 16,
                                    fontWeight: isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Glissez ou utilisez les flèches pour choisir un mode',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'v1.0 © TonStudio',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GameModeCard {
  final String label;
  final GameMode? mode;
  final Difficulty? difficulty;
  final bool disabled;

  _GameModeCard({
    required this.label,
    this.mode,
    this.difficulty,
    this.disabled = false,
  });
}