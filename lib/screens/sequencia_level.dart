import 'package:flutter/material.dart';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import 'sequencia_recall.dart';

class SequenciaLevel extends StatelessWidget {
  final GameMode mode;
  const SequenciaLevel({Key? key, required this.mode}) : super(key: key);

  final List<GameConfig> sequenceConfigs = const [
    GameConfig(mode: GameMode.sequenceRecall, rows: 3, columns: 3, levelTitle: 'Fàcil (3x3)', sequenceLength: 3),
    GameConfig(mode: GameMode.sequenceRecall, rows: 4, columns: 4, levelTitle: 'Mitjà (4x4)', sequenceLength: 5),
    GameConfig(mode: GameMode.sequenceRecall, rows: 5, columns: 5, levelTitle: 'Difícil (5x5)', sequenceLength: 7),
  ];

  void _startGame(BuildContext context, GameConfig config) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SequenciaRecall(config: config),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nivell', style: AppStyles.appBarText),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: sequenceConfigs.map((config) {
            return Padding(
              padding: const EdgeInsets.all(15),
              child: ElevatedButton(
                onPressed: () => _startGame(context, config),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(280, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(config.levelTitle, style: AppStyles.levelText),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}