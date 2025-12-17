import 'package:flutter/material.dart';
import 'package:memo/screens/menu.dart';
import '../styles/app_styles.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/brain.png',
                fit: BoxFit.contain,
                height: 750,
              ),
              Center(
                child: Text(
                  'Memorium',
                  style: AppStyles.appName,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () =>
        Navigator.push(context, MaterialPageRoute(builder: (context) => Menu()))
    );
  }
}