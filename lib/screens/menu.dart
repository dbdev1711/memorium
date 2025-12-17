import 'package:flutter/material.dart';
import 'package:memo/styles/app_styles.dart';
import '../models/game_config.dart';
import 'operations_level.dart';
import 'parelles_level.dart';
import 'sequencia_level.dart';
import 'number_level.dart';
import 'alphabet_level.dart';
import 'profile.dart';

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  void _navigateToModeSelection(BuildContext context, GameMode mode) {
    Widget targetScreen;

    switch (mode) {
      case GameMode.classicMatch:
        targetScreen = ParellesLevel(mode: mode);
        break;
      case GameMode.sequenceRecall:
        targetScreen = SequenciaLevel(mode: mode);
        break;
      case GameMode.numberRecall:
        targetScreen = NumberLevel(mode: mode);
        break;
      case GameMode.alphabetRecall:
        targetScreen = AlphabetLevel(mode: mode);
        break;
      case GameMode.operations:
        targetScreen = OperationsLevel(mode: mode);
        break;
      case GameMode.profile:
        targetScreen = const Profile();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => targetScreen,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Memorium', style: AppStyles.appBarText),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: GameMode.values.map((mode) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () => _navigateToModeSelection(context, mode),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(270, 70),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(mode.title, style: AppStyles.menuButtonTitle),
                    const SizedBox(height: 4),
                    Text(mode.description, style: AppStyles.menuButtonDesc),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}