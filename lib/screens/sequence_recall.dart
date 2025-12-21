import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_item.dart';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import '../widgets/card.dart';
import '../widgets/result_panel.dart';

class SequenceRecall extends StatefulWidget {
  final GameConfig config;
  final String language;

  const SequenceRecall({Key? key, required this.config, required this.language}) : super(key: key);

  @override
  State<SequenceRecall> createState() => _SequenceRecallState();
}

class _SequenceRecallState extends State<SequenceRecall> {
  List<CardItem> _cards = [];
  List<CardItem> _sequence = [];
  int _sequenceStep = 0;
  bool _isChecking = false;
  bool _showResultPanel = false;
  String _resultTitle = '';
  String _resultMessage = '';
  Color _resultColor = Colors.green;
  final Stopwatch _stopwatch = Stopwatch();

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
      _stopwatch.reset();

      for (int i = 0; i < widget.config.totalCards; i++) {
        _cards.add(CardItem(id: i, content: '🔴'));
      }

      List<CardItem> shuffled = List.from(_cards)..shuffle(Random());
      _sequence = shuffled.sublist(0, widget.config.sequenceLength);

      Future.delayed(const Duration(milliseconds: 500), _showSequence);
    });
  }

  void _showSequence() {
    if (!mounted) return;
    setState(() => _isChecking = true);
    final int diff = widget.config.sequenceLength - 2;
    final baseDelay = 600 + (diff * 200);
    final showDuration = 800 + (diff * 300);

    for (int i = 0; i < _sequence.length; i++) {
      final cardIdx = _cards.indexOf(_sequence[i]);
      Future.delayed(Duration(milliseconds: baseDelay * i), () {
        if (mounted) setState(() => _cards[cardIdx] = _cards[cardIdx].copyWith(isFlipped: true));
      }).then((_) {
        Future.delayed(Duration(milliseconds: showDuration), () {
          if (mounted) setState(() => _cards[cardIdx] = _cards[cardIdx].copyWith(isFlipped: false));
          if (i == _sequence.length - 1) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) setState(() => _isChecking = false);
            });
          }
        });
      });
    }
  }

  void _handleCardTap(CardItem card) {
    if (_isChecking || card.isFlipped) return;
    if (_sequenceStep == 0) _stopwatch.start();

    setState(() => _cards[_cards.indexOf(card)] = card.copyWith(isFlipped: true));

    if (card.id == _sequence[_sequenceStep].id) {
      _sequenceStep++;
      if (_sequenceStep == _sequence.length) {
        _stopwatch.stop();
        _saveAndShow(true);
      } else {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) setState(() => _cards[_cards.indexOf(card)] = card.copyWith(isFlipped: false));
        });
      }
    } else {
      _stopwatch.stop();
      _saveAndShow(false);
    }
  }

  Future<void> _saveAndShow(bool win) async {
    String timeStr = "";
    if (win) {
      final ms = _stopwatch.elapsedMilliseconds;
      final prefs = await SharedPreferences.getInstance();

      // DETERMINACIÓ DEL NIVELL
      String levelKey;
      if (widget.config.columns <= 3) {
        levelKey = "Facil";
      } else if (widget.config.columns <= 4) {
        levelKey = "Mitja";
      } else {
        levelKey = "Dificil";
      }

      String storageKey = 'time_sequencia_$levelKey';
      int lastBest = prefs.getInt(storageKey) ?? 99999999;

      if (ms < lastBest) {
        await prefs.setInt(storageKey, ms);
        print("Nova millor marca en $levelKey (Seqüència): $ms ms");
      }

      final sec = _stopwatch.elapsed.inSeconds.remainder(60);
      final min = _stopwatch.elapsed.inMinutes;

      String timeLabel = widget.language == 'cat' ? 'Temps' : (widget.language == 'esp' ? 'Tiempo' : 'Time');
      timeStr = min > 0 ? "\n$timeLabel: ${min}m ${sec}s" : "\n$timeLabel: ${sec}s";
    }

    setState(() {
      _isChecking = true;
      _showResultPanel = true;
      _resultColor = win ? Colors.green : Colors.red;

      _resultTitle = win
          ? (widget.language == 'cat' ? '🏆 Correcte!' : widget.language == 'esp' ? '🏆 ¡Correcto!' : '🏆 Correct!')
          : '❌ Error!';

      _resultMessage = (win
          ? (widget.language == 'cat' ? 'Seqüència completada!' : widget.language == 'esp' ? '¡Secuencia completada!' : 'Sequence completed!')
          : (widget.language == 'cat' ? 'Ho pots fer millor!' : widget.language == 'esp' ? '¡Puedes hacerlo mejor!' : 'You can do it better!'))
          + timeStr;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.language == 'cat' ? 'Seqüència' : widget.language == 'esp' ? 'Secuencia' : 'Sequence', style: AppStyles.appBarText),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _initializeGame)],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isChecking
              ? AppStyles.sizedBoxHeight70
              : Column(children: [
                  Text(widget.language == 'cat' ? 'Repeteix la seqüència' : widget.language == 'esp' ? 'Repite la secuencia' : 'Repeat the sequence', style: const TextStyle(fontSize: 18)),
                  Text('${widget.language == 'cat' ? 'Pas' : widget.language == 'esp' ? 'Paso' : 'Step'}: $_sequenceStep / ${_sequence.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                ])
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IgnorePointer(
              ignoring: _isChecking,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: widget.config.columns, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemCount: _cards.length,
                itemBuilder: (context, i) => CardWidget(key: ValueKey(_cards[i].id), card: _cards[i], onTap: () => _handleCardTap(_cards[i])),
              ),
            ),
          ),
        ),
        if (_showResultPanel) ResultPanel(title: _resultTitle, message: _resultMessage, color: _resultColor, onRestart: _initializeGame, language: widget.language),
      ]),
    );
  }
}