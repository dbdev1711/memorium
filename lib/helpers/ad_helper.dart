import 'dart:io';

class AdHelper {
  // APP ID (per a la teva referència): ca-app-pub-5335679604691429~5297365530

  static String get interstitialAdUnitId {
    // Aquest mètode es pot sobrecarregar o pots crear un per cada joc
    // Però per fer-ho més fàcil, crearem un mètode que rebi el tipus de joc
    return '';
  }

  static String getInterstitialAdId(String gameType) {
    if (Platform.isAndroid) {
      switch (gameType) {
        case 'alphabet':
          return 'ca-app-pub-5335679604691429/4097455197';
        case 'numbers':
          return 'ca-app-pub-5335679604691429/6034171635';
        case 'operations':
          return 'ca-app-pub-5335679604691429/6452155798';
        case 'parelles':
          return 'ca-app-pub-5335679604691429/8966638495';
        case 'sequence':
          return 'ca-app-pub-5335679604691429/5139074123';
        default:
          // ID de test per si de cas el nom no coincideix
          return 'ca-app-pub-3940256099942544/1033173712';
      }
    }
    else {
      // Si mai fas l'app per a iOS, aquí anirien els IDs de test d'Apple
      return 'ca-app-pub-3940256099942544/4411468910';
    }
  }
}