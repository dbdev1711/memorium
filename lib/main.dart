import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memo/screens/menu.dart';
import 'package:memo/screens/idioma.dart';
import 'styles/app_styles.dart';

void main() async {
  // 1. Assegura que Flutter estigui inicialitzat
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicialitza l'SDK d'anuncis de Google
  await MobileAds.instance.initialize();

  // 3. Registra el teu Pixel 7a com a dispositiu de prova (MOLT IMPORTANT)
  // Això evita que Google bloquegi el teu compte AdMob per "clics invàlids"
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: ["69B5C8BFFA8C4CC0CA334A51DA5028DA"],
    ),
  );

  // 4. Carrega les preferències (idioma, primer inici)
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

  // 5. Arrenca l'aplicació
  runApp(App(isFirstRun: isFirstRun));
}

class App extends StatelessWidget {
  final bool isFirstRun;
  const App({Key? key, required this.isFirstRun}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memorium',
      theme: AppStyles.lightTheme,
      // Si és el primer cop, va a la selecció d'idioma. Si no, al Menú.
      home: isFirstRun ? const Idioma() : const Menu(),
    );
  }
}