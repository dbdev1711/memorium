import 'package:flutter/material.dart';
import 'styles/app_styles.dart';
import 'screens/home.dart';

void main() => runApp(const App());


class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memorium',
      theme: AppStyles.lightTheme,
      home: const Home(),
    );
  }
}