import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_item.dart';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import '../widgets/card.dart';
import '../widgets/result_panel.dart';

class NumberRecall extends StatefulWidget {
  final GameConfig config;
  final String language;
  const NumberRecall({Key? key, required this.config, required this.language}) : super(key: key);
  @override
  State<NumberRecall> createState() => _NumberRecallState();
}

class _NumberRecallState extends State<NumberRecall> {
  List<CardItem> _cards = [];
  int _currentNumber = 1;
  int _gameState = 0; // 0: Mem, 1: Play, 2: End
  bool _showResultPanel = false;
  String _resultTitle = '';
  String _resultMessage = '';
  Color _resultColor = Colors.green;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() { super.initState(); _initializeGame(); }

  void _initializeGame() {
    setState(() {
      _cards.clear(); _currentNumber = 1; _gameState = 0; _showResultPanel = false; _stopwatch.reset();
      int total = widget.config.rows * widget.config.columns;
      int req = min(widget.config.requiredNumbers, total);
      List<int> idxs = List.generate(total, (i) => i)..shuffle();
      for (int i = 0; i < total; i++) {
        int pos = idxs.indexOf(i);
        _cards.add(CardItem(id: i, content: pos < req ? (pos + 1).toString() : '', isFlipped: pos < req));
      }
    });
    int sec = widget.config.rows <= 3 ? 2 : (widget.config.rows <= 4 ? 4 : 6);
    Timer(Duration(seconds: sec), () {
      if (mounted) setState(() { _cards = _cards.map((c) => c.copyWith(isFlipped: false)).toList(); _gameState = 1; _stopwatch.start(); });
    });
  }

  void _handleCardTap(CardItem card) {
    if (_gameState != 1 || card.isFlipped) return;
    if (card.content == _currentNumber.toString()) {
      setState(() {
        _cards[_cards.indexOf(card)] = card.copyWith(isFlipped: true, isMatched: true);
        if (_currentNumber == widget.config.requiredNumbers) { _stopwatch.stop(); _finish(true); }
        else { _currentNumber++; }
      });
    } else { _stopwatch.stop(); _finish(false); }
  }

  Future<void> _finish(bool win) async {
    String timeStr = "";
    if (win) {
      final ms = _stopwatch.elapsedMilliseconds;
      final prefs = await SharedPreferences.getInstance();
      if (ms < (prefs.getInt('time_number') ?? 99999999)) await prefs.setInt('time_number', ms);

      final sec = _stopwatch.elapsed.inSeconds.remainder(60);
      final min = _stopwatch.elapsed.inMinutes;

      String timeLabel = widget.language == 'cat' ? 'Temps' : (widget.language == 'esp' ? 'Tiempo' : 'Time');
      timeStr = min > 0 ? "\n$timeLabel: ${min}m ${sec}s" : "\n$timeLabel: ${sec}s";
    }

    setState(() {
      _gameState = 2;
      _cards = _cards.map((c) => c.copyWith(isFlipped: true)).toList();
      _showResultPanel = true;
      _resultColor = win ? Colors.green : Colors.red;

      if (win) {
        _resultTitle = widget.language == 'cat' ? '🏆 Èxit!' : (widget.language == 'esp' ? '🏆 ¡Éxito!' : '🏆 Success!');
        _resultMessage = (widget.language == 'cat' ? 'Números trobats!' : (widget.language == 'esp' ? '¡Números encontrados!' : 'Numbers found!')) + timeStr;
      } else {
        _resultTitle = '❌ Error!';
        String errorText = widget.language == 'cat' ? 'Era el número' : (widget.language == 'esp' ? 'Era el número' : 'It was number');
        _resultMessage = '$errorText $_currentNumber';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = widget.language == 'cat' ? 'Numèric' : (widget.language == 'esp' ? 'Numérico' : 'Numbers');

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle, style: AppStyles.appBarText),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _gameState == 0 ? null : _initializeGame)]
      ),
      body: Column(
        children: [
          AppStyles.sizedBoxHeight20,
          // Aquest bloc desapareix quan _showResultPanel és true
          if (!_showResultPanel)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                _gameState == 0
                  ? (widget.language == 'cat' ? 'Memoritza els números' : widget.language == 'esp' ? 'Memoriza los números' : 'Remember the numbers')
                  : '${widget.language == 'cat' ? 'Busca el ' : widget.language == 'esp' ? 'Busca el ' : 'Find '}$_currentNumber',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
            ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.config.columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10
                ),
                itemCount: _cards.length,
                itemBuilder: (context, i) => CardWidget(
                  card: _cards[i],
                  onTap: () => _handleCardTap(_cards[i]),
                  isNumberMode: true
                )
              )
            )
          ),

          if (_showResultPanel)
            ResultPanel(
              title: _resultTitle,
              message: _resultMessage,
              color: _resultColor,
              onRestart: _initializeGame,
              language: widget.language
            ),
        ]),
    );
  }
}