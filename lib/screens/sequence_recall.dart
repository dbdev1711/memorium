import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/ad_helper.dart';
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
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _loadAd();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.getInterstitialAdId('sequence'),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadAd();
            },
          );
          if (mounted) {
            setState(() {
              _interstitialAd = ad;
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (err) {
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
          debugPrint('Error carregant anunci seqüència: ${err.message}');
        },
      ),
    );
  }

  void _initializeGame() {
    setState(() {
      _cards.clear();
      _sequence.clear();
      _sequenceStep = 0;
      _isChecking = false;
      _showResultPanel = false;
      _stopwatch.reset();

      // 1. Creem totes les cartes buides per defecte
      for (int i = 0; i < widget.config.totalCards; i++) {
        _cards.add(CardItem(id: i, content: ''));
      }

      // 2. Triem quines cartes formaran la seqüència
      List<CardItem> shuffled = List.from(_cards)..shuffle(Random());
      List<CardItem> selectedItems = shuffled.sublist(0, widget.config.sequenceLength);

      // 3. Assignem el punt vermell NOMÉS a les cartes de la seqüència
      for (var seqItem in selectedItems) {
        int idx = _cards.indexWhere((c) => c.id == seqItem.id);
        _cards[idx] = _cards[idx].copyWith(content: '🔴');
      }

      // 4. Guardem la seqüència d'IDs per a la comprovació posterior
      _sequence = selectedItems.map((c) => c.copyWith(content: '🔴')).toList();

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
      final cardIdx = _cards.indexWhere((c) => c.id == _sequence[i].id);
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

    // Girem la carta premuda: mostrarà 🔴 si en té, o res si estava buida
    setState(() => _cards[_cards.indexOf(card)] = card.copyWith(isFlipped: true));

    if (card.id == _sequence[_sequenceStep].id) {
      // ÉS CORRECTE
      _sequenceStep++;
      if (_sequenceStep == _sequence.length) {
        _stopwatch.stop();
        _saveAndShow(true);
      } else {
        // Feedback visual: la girem i la tornem a amagar
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) setState(() => _cards[_cards.indexOf(card)] = card.copyWith(isFlipped: false));
        });
      }
    } else {
      // ÉS ERROR: Aturem i mostrem panel. La carta queda girada (i buida)
      _stopwatch.stop();
      _saveAndShow(false);
    }
  }

  Future<void> _saveAndShow(bool win) async {
    String timeStr = "";
    if (win) {
      final ms = _stopwatch.elapsedMilliseconds;
      final prefs = await SharedPreferences.getInstance();

      String levelKey = widget.config.columns <= 3 ? "Facil" : (widget.config.columns <= 4 ? "Mitja" : "Dificil");
      String storageKey = 'time_sequencia_$levelKey';
      int lastBest = prefs.getInt(storageKey) ?? 99999999;

      if (ms < lastBest) {
        await prefs.setInt(storageKey, ms);
      }

      final sec = _stopwatch.elapsed.inSeconds.remainder(60);
      final min = _stopwatch.elapsed.inMinutes;
      String timeLabel = widget.language == 'cat' ? 'Temps' : (widget.language == 'esp' ? 'Tiempo' : 'Time');
      timeStr = min > 0 ? "\n$timeLabel: ${min}m ${sec}s" : "\n$timeLabel: ${sec}s";
    }

    void displayResultUI() {
      if (!mounted) return;
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

    if (_isAdLoaded && _interstitialAd != null && AdHelper.shouldShowAd()) {
      _interstitialAd!.show().then((_) {
        displayResultUI();
        _isAdLoaded = false;
        _interstitialAd = null;
      });
    } else {
      displayResultUI();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.language == 'cat' ? 'Seqüència' : widget.language == 'esp' ? 'Secuencia' : 'Sequence', style: AppStyles.appBarText),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _initializeGame)],
      ),
      body: SafeArea(
        child: Column(children: [
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Càlcul dinàmic per iPad per evitar desbordaments verticals
                    final double width = constraints.maxWidth;
                    final double height = constraints.maxHeight;

                    final double cellWidth = width / widget.config.columns;
                    final double cellHeight = height / widget.config.rows;

                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(), // Bloqueig de scroll
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.config.columns,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: cellWidth / cellHeight, // Ajust de proporció segons pantalla
                      ),
                      itemCount: _cards.length,
                      itemBuilder: (context, i) => CardWidget(
                        key: ValueKey(_cards[i].id),
                        card: _cards[i],
                        onTap: () => _handleCardTap(_cards[i])
                      ),
                    );
                  }
                ),
              ),
            ),
          ),
          if (_showResultPanel) ResultPanel(title: _resultTitle, message: _resultMessage, color: _resultColor, onRestart: _initializeGame, language: widget.language),
        ]),
      ),
    );
  }
}
