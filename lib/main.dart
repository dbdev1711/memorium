import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:upgrader/upgrader.dart';
import 'screens/menu.dart';
import 'screens/idioma.dart';
import 'styles/app_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;
  final String savedLang = prefs.getString('language') ?? 'cat';

  await _initTracking();

  await MobileAds.instance.initialize();

  runApp(App(isFirstRun: isFirstRun, savedLang: savedLang));
}

Future<void> _initTracking() async {
  await Future.delayed(const Duration(milliseconds: 1000));
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined) {
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
}

class App extends StatelessWidget {
  final bool isFirstRun;
  final String savedLang;

  const App({super.key, required this.isFirstRun, required this.savedLang});

  String _getUpgraderCode() {
    switch (savedLang) {
      case 'esp':
        return 'es';
      case 'eng':
        return 'en';
      case 'cat':
      default:
        return 'ca';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String langCode = _getUpgraderCode();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memoriumm',
      theme: AppStyles.lightTheme,
      home: UpgradeAlert(
        upgrader: Upgrader(
          languageCode: langCode,
          messages: UpgraderMessages(code: langCode),
          durationUntilAlertAgain: const Duration(days: 1),
        ),
        child: isFirstRun ? const Idioma() : const Menu(),
      ),
    );
  }
}