// pages/game_mode_selection_page.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import '../models/game_mode.dart';
import '../services/ai_service.dart';
import 'game_page.dart';

class GameModeSelectionPage extends StatefulWidget {
  const GameModeSelectionPage({super.key});

  @override
  State<GameModeSelectionPage> createState() => _GameModeSelectionPageState();
}

class _GameModeSelectionPageState extends State<GameModeSelectionPage> {
  final PageController _pageController = PageController(viewportFraction: 0.33);
  int _currentIndex = 0;
  final FocusNode _focusNode = FocusNode();

  final List<_GameModeCard> _cards = [
    _GameModeCard(
      label: 'Solo - Facile',
      mode: GameMode.playerVsAI,
      difficulty: Difficulty.easy,
    ),
    _GameModeCard(
      label: 'Solo - Difficile',
      mode: GameMode.playerVsAI,
      difficulty: Difficulty.hard,
    ),
    _GameModeCard(label: 'Deux joueurs', mode: GameMode.playerVsPlayer),
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
    if (card.difficulty != null) AIService.difficulty = card.difficulty!;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GamePage(mode: card.mode!)),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
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
              children: [
                const SizedBox(height: 32),
                SizedBox(
                  height: constraints.maxHeight * 0.6,
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
                      return GestureDetector(
                        onTap: () => _onCardTap(card),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 20,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            image: DecorationImage(
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
                                  color: Colors.black26,
                                  offset: const Offset(0, 6),
                                  blurRadius: 10,
                                ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
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
                const SizedBox(height: 16),
                Text(
                  'Glissez ou utilisez les flèches pour choisir un mode',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 32),
                const Text(
                  'v1.0 © TonStudio',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 12),
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