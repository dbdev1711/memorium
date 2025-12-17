import 'package:flutter/material.dart';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import 'number_recall.dart';

class NumberLevel extends StatelessWidget {
  final GameMode mode;
  const NumberLevel({Key? key, required this.mode}) : super(key: key);

  // Configuracions predefinides per al mode Numèric
  final List<GameConfig> numberConfigs = const [
    GameConfig(mode: GameMode.numberRecall, rows: 3, columns: 3, levelTitle: 'Fàcil (3x3)', requiredNumbers: 4),
    GameConfig(mode: GameMode.numberRecall, rows: 4, columns: 4, levelTitle: 'Mitjà (4x4)', requiredNumbers: 6),
    GameConfig(mode: GameMode.numberRecall, rows: 5, columns: 5, levelTitle: 'Difícil (5x5)', requiredNumbers: 8),
  ];

  void _startGame(BuildContext context, GameConfig config) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NumberRecall(config: config),
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
          children: numberConfigs.map((config) {
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