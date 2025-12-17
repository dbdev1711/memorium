import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../screens/menu.dart';

class ResultPanel extends StatelessWidget {
  final String title;
  final String message;
  final Color color;
  final VoidCallback onRestart;
  final VoidCallback? onBackToLevels;

  const ResultPanel({
    Key? key,
    required this.title,
    required this.message,
    required this.color,
    required this.onRestart,
    this.onBackToLevels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Menu()),
                  );
                },
                child: const Text('Menú', style: AppStyles.textButtonDialog),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onBackToLevels ??
                    () {
                      Navigator.pop(context);
                    },
                child: const Text('Nivells', style: AppStyles.textButtonDialog),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onRestart,
                child: const Text('Reinicia', style: AppStyles.textButtonDialog),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
