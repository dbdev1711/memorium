import 'package:flutter/material.dart';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import 'operations_recall.dart';

class OperationsLevel extends StatelessWidget {
  final GameMode mode;
  const OperationsLevel({Key? key, required this.mode}) : super(key: key);

  final List<GameConfig> opConfigs = const [
    GameConfig(
      mode: GameMode.operations,
      sequenceLength: 4,
      levelTitle: 'Fàcil (4 operacions)'
    ),
    GameConfig(
      mode: GameMode.operations,
      sequenceLength: 6,
      levelTitle: 'Mitjà (6 operacions)'
    ),
    GameConfig(
      mode: GameMode.operations,
      sequenceLength: 8,
      levelTitle: 'Difícil (8 operacions)'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nivell', style: AppStyles.appBarText),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: opConfigs.map((config) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OperationsRecall(config: config)
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(250, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                  ),
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