// lib/models/game_config.dart (Definició COMPLETA)

enum GameMode {
  classicMatch(
    title: 'Parelles',
    description: 'Troba totes les parelles iguals.',
  ),
  sequenceRecall(
    title: 'Seqüència',
    description: 'Reprodueix l\'ordre correcte.',
  ),
  numberRecall(
    title: 'Numèric',
    description: 'Recorda els números per ordre.',
  ),
  operations(
    title: 'Operacions',
    description: 'Calcula i ordena ascendentment.',
  ),
  alphabetRecall(
    title: 'Alfabètic',
    description: 'Recorda les lletres per ordre.',
  ),
  profile(
    title: 'Perfil',
    description: 'Estadístiques i configuració.',
  );

  final String title;
  final String description;

  const GameMode({required this.title, required this.description});
}

class GameConfig {
  final GameMode mode;
  final int rows;
  final int columns;
  final String levelTitle;

  final int requiredPairs;
  final int sequenceLength;
  final int requiredNumbers;

  const GameConfig({
    required this.mode,
    this.rows = 4,
    this.columns = 4,
    this.levelTitle = 'Nivell Personalitzat',
    this.requiredPairs = 8,
    this.sequenceLength = 4,
    this.requiredNumbers = 4,
  }) : assert(rows > 0 && columns > 0);

  int get totalCards => rows * columns;
}