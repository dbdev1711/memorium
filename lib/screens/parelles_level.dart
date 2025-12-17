import 'package:flutter/material.dart';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import 'parelles_recall.dart';

class ParellesLevel extends StatelessWidget {
  final GameMode mode;
  const ParellesLevel({Key? key, required this.mode}) : super(key: key);

  final List<GameConfig> classicConfigs = const [
    GameConfig(mode: GameMode.classicMatch, rows: 4, columns: 4, levelTitle: 'Fàcil (4x4)'),
    GameConfig(mode: GameMode.classicMatch, rows: 6, columns: 6, levelTitle: 'Mitjà (6x6)'),
    GameConfig(mode: GameMode.classicMatch, rows: 8, columns: 8, levelTitle: 'Difícil (8x8)'),
  ];

  void _startGame(BuildContext context, GameConfig config) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParellesRecall(config: config),
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
          children: classicConfigs.map((config) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () => _startGame(context, config),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 60),
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