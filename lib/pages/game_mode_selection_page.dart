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

  final List<_GameModeCard> _cards = [
    _GameModeCard(
      label: 'Facile',
      imageName: 'bg_solo_facile.jpg',
      mode: GameMode.playerVsAI,
      difficulty: Difficulty.easy,
    ),
    _GameModeCard(
      label: 'Moyen',
      imageName: 'bg_solo_intermediaire.jpg',
      mode: GameMode.playerVsAI,
      difficulty: Difficulty.medium,
    ),
    _GameModeCard(
      label: 'Difficile',
      imageName: 'bg_solo_difficile.jpg',
      mode: GameMode.playerVsAI,
      difficulty: Difficulty.hard,
    ),
    _GameModeCard(
      label: 'Duo',
      imageName: 'bg_deux_joueurs.jpg',
      mode: GameMode.playerVsPlayer
    ),
    _GameModeCard(
      label: 'Duo+',
      imageName: 'bg_mode_evolutif.jpg',
      mode: GameMode.evolving
    ),
    _GameModeCard(
      label: 'En ligne',
      imageName: 'bg_en_ligne.jpg',
      mode: null, 
      disabled: true
    ),
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
    // Récupère la carte actuellement active pour connaître l'image de fond
    final activeCard = _cards[_currentIndex];

    return Scaffold(
      // On retire la couleur de fond ici, car le Stack va la gérer
      // backgroundColor: const Color(0xFFE6F0FA),
      body: Stack(
        // On utilise un Stack pour superposer les couches
        children: [
          // ===================================================================
          // COUCHE 1 : L'image de fond animée
          // ===================================================================
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Image.asset(
              // Utilise le getter de la carte active pour trouver l'image
              activeCard.imagePath,
              // Clé unique pour que AnimatedSwitcher détecte le changement d'image
              key: ValueKey<String>(activeCard.imagePath),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              // Gère les erreurs si une image n'est pas trouvée
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF2E4C6D),
                ); // Une couleur de secours
              },
            ),
          ),

          // ===================================================================
          // COUCHE 2 : L'effet de flou
          // ===================================================================
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 15.0,
              sigmaY: 15.0,
            ), // Force du flou
            child: Container(
              // Ajoute une légère teinte sombre pour améliorer la lisibilité du texte
              color: Colors.black.withAlpha(51),
            ),
          ),

          // ===================================================================
          // COUCHE 3 : Le contenu original de votre page
          // ===================================================================
          KeyboardListener(
            focusNode: _focusNode,
            onKeyEvent: _handleKeyEvent,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: constraints.maxHeight * 0.9,
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
                          final double scale = isActive ? 1.0 : 0.8;

                          final double cardWidth =
                              constraints.maxWidth *
                              _pageController.viewportFraction;
                          final double widthIncrease = cardWidth * 0.3;
                          final double marginForNeighbor = widthIncrease / 2;

                          EdgeInsets margin = const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 20,
                          );

                          if (index == _currentIndex - 1) {
                            margin = margin.copyWith(
                              right: margin.right + marginForNeighbor,
                            );
                          }

                          if (index == _currentIndex + 1) {
                            margin = margin.copyWith(
                              left: margin.left + marginForNeighbor,
                            );
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
                                  image: AssetImage(card.imagePath),
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
                                      color: Colors.black.withAlpha(76),
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
                                      color: Colors.black.withAlpha(153),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      card.label,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'RobotoCondensed',
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
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        'Glissez ou utilisez les flèches pour choisir un mode',
                        style: TextStyle(
                          color: Colors.white.withAlpha(204),
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 2),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Text(
                        'v1.0 © Denis declercq',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withAlpha(179),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GameModeCard {
  final String label;
  final String imageName;
  final GameMode? mode;
  final Difficulty? difficulty;
  final bool disabled;

  _GameModeCard({
    required this.label,
    required this.imageName,
    this.mode,
    this.difficulty,
    this.disabled = false,
  });

  String get imagePath {
    return 'assets/images/$imageName';
  }
}
