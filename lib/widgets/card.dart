// lib/widgets/card.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/card_item.dart';

class CardWidget extends StatefulWidget {
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
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  // Colors Pantone Blau
  final List<Color> pantoneBlues = [
    const Color(0xFF0038A8), // Pantone 288C
    const Color(0xFF0057B7), // Pantone 299C
    const Color(0xFF00AEEF), // Pantone 2995C
    const Color(0xFF1974D2), // Pantone 293C
    const Color(0xFF1E90FF), // Pantone 300C
    const Color(0xFF4169E1), // Pantone 2728C
    const Color(0xFF4682B4), // Pantone 652C
    const Color(0xFF6495ED), // Pantone 279C
    const Color(0xFF87CEEB), // Pantone Sky Blue
    const Color(0xFF87CEFA), // Pantone 2975C
  ];

  final Random _random = Random();
  Color? _pantoneColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.card.isFlipped
              ? (widget.isNumberMode && widget.card.content.isEmpty
                  ? Colors.grey[200]
                  : Colors.white)  // ← Blanc quan es gira
              : (_pantoneColor ??= pantoneBlues[_random.nextInt(pantoneBlues.length)]),  // ← Pantone aleatori quan tapada
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.deepPurple, width: 2),
        ),
        child: Center(
          child: widget.card.isFlipped
              ? Text(
                  widget.card.content,
                  style: TextStyle(
                    fontSize: widget.isNumberMode ? 32 : 40,
                    fontWeight: widget.isNumberMode ? FontWeight.bold : FontWeight.normal,
                    color: Colors.black
                  ),
                )
              : const Text(''),
        ),
      ),
    );
  }
}
