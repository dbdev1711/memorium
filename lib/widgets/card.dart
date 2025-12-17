// lib/widgets/card.dart (Implementació suggerida)

import 'package:flutter/material.dart';
import '../models/card_item.dart';

class CardWidget extends StatelessWidget {
  final CardItem card;
  final VoidCallback onTap;
  final bool isNumberMode;

  const CardWidget({
    Key? key,
    required this.card,
    required this.onTap,
    this.isNumberMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: card.isFlipped ? (isNumberMode && card.content.isEmpty ?
          Colors.grey[200] : Colors.white) : Colors.yellow,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.deepPurple, width: 2),
        ),
        child: Center(
          child: card.isFlipped
              ? Text(
                  card.content,
                  style: TextStyle(
                    fontSize: isNumberMode ? 32 : 40, // Mida més gran per a números
                    fontWeight: isNumberMode ? FontWeight.bold : FontWeight.normal,
                    color: isNumberMode ? Colors.black : Colors.black, // Color negre per a números
                  ),
                )
              : const Text(
                  '', // La carta tapada no mostra res
                ),
        ),
      ),
    );
  }
}