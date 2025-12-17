import 'package:flutter/material.dart';
import 'dart:math';
import '../models/card_item.dart';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import '../widgets/card.dart';
import '../widgets/result_panel.dart';

class SequenciaRecall extends StatefulWidget {
  final GameConfig config;

  const SequenciaRecall({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  State<SequenciaRecall> createState() => _SequenciaRecallState();
}

class _SequenciaRecallState extends State<SequenciaRecall> {
  List<CardItem> _cards = [];
  List<CardItem> _sequence = [];
  int _sequenceStep = 0;
  bool _isChecking = false;

  bool _showResultPanel = false;
  String _resultTitle = '';
  String _resultMessage = '';
  Color _resultColor = Colors.green;

  final String _singleCardContent = '🔴';

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    setState(() {
      _cards.clear();
      _sequence.clear();
      _sequenceStep = 0;
      _isChecking = false;
      _showResultPanel = false;

      int totalCards = widget.config.totalCards;

      for (int i = 0; i < totalCards; i++) {
        _cards.add(CardItem(id: i, content: _singleCardContent));
      }

      List<CardItem> shuffledCards = List.from(_cards);
      shuffledCards.shuffle(Random());

      _sequence = shuffledCards.sublist(0, widget.config.sequenceLength);

      Future.delayed(const Duration(milliseconds: 500), () {
        _showSequence();
      });
    });
  }

  void _showSequence() {
    setState(() => _isChecking = true);

    for (int i = 0; i < _sequence.length; i++) {
      final cardToShow = _sequence[i];
      final cardIndex = _cards.indexOf(cardToShow);

      Future.delayed(Duration(milliseconds: 600 * i), () {
        if (!mounted) return;
        setState(() =>
            _cards[cardIndex] = cardToShow.copyWith(isFlipped: true));
      }).then((_) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          setState(() =>
              _cards[cardIndex] = _cards[cardIndex].copyWith(isFlipped: false));

          if (i == _sequence.length - 1) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (!mounted) return;
              setState(() => _isChecking = false);
            });
          }
        });
      });
    }
  }

  void _revealAllCards() {
    setState(() {
      _cards = _cards.map((c) => c.copyWith(isFlipped: true)).toList();
    });
  }

  void _handleCardTap(CardItem card) {
    if (_isChecking || card.isFlipped) return;

    setState(() {
      _cards[_cards.indexOf(card)] = card.copyWith(isFlipped: true);
    });

    if (_sequenceStep < _sequence.length &&
        card.id == _sequence[_sequenceStep].id) {
      // ✅ PAS CORRECTE
      _sequenceStep++;

      if (_sequenceStep == _sequence.length) {
        _isChecking = true;
        _showGamePanel(win: true);
      } else {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          setState(() {
            _cards[_cards.indexOf(card)] = card.copyWith(isFlipped: false);
          });
        });
      }
    } else {
      // ❌ PAS INCORRECTE
      _isChecking = true;
      _showGamePanel(win: false);
    }
  }

  void _showGamePanel({required bool win}) {
    _revealAllCards();
    setState(() {
      _showResultPanel = true;
      _resultColor = win ? Colors.green : Colors.red;
      _resultTitle = win ? '🏆 Correcte!' : '❌ Seqüència incorrecta!';
      _resultMessage = win
          ? 'Has completat la seqüència amb èxit!'
          : 'Ho pots fer millor! Reinicia i torna-ho a provar.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seqüència', style: AppStyles.appBarText),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isChecking ? null : _initializeGame,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Item: $_sequenceStep / ${_sequence.length}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IgnorePointer(
                ignoring: _isChecking,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.config.columns,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    return CardWidget(
                      key: ValueKey(card.id),
                      card: card,
                      onTap: () => _handleCardTap(card),
                    );
                  },
                ),
              ),
            ),
          ),
          if (_showResultPanel)
            ResultPanel(
              title: _resultTitle,
              message: _resultMessage,
              color: _resultColor,
              onRestart: _initializeGame,
            ),
        ],
      ),
    );
  }
}