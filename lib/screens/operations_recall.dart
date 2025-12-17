import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import '../widgets/result_panel.dart';

class OperationItem {
  final String expression;
  final int result;
  bool isSelected = false;

  OperationItem(this.expression, this.result);
}

class OperationsRecall extends StatefulWidget {
  final GameConfig config;
  const OperationsRecall({Key? key, required this.config}) : super(key: key);

  @override
  State<OperationsRecall> createState() => _OperationsRecallState();
}

class _OperationsRecallState extends State<OperationsRecall> {
  late List<OperationItem> _operations;
  final List<OperationItem> _userOrder = [];

  bool _isGameOver = false;
  bool _showResultPanel = false;
  String _resultTitle = '';
  String _resultMessage = '';
  Color _resultColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _generateOperations();
  }

  void _generateOperations() {
    final random = Random();
    _operations = List.generate(widget.config.sequenceLength, (index) {
      int type = random.nextInt(4);

      switch (type) {
        case 0: // SUMA
          int a = random.nextInt(10) + 1; // 1-10
          int b = random.nextInt(10) + 1; // 1-10
          return OperationItem("$a + $b", a + b);

        case 1: // RESTA
          int a = random.nextInt(10) + 1; // 1-10
          int b = random.nextInt(10) + 1; // 1-10
          if (a < b) {
            final temp = a;
            a = b;
            b = temp;
          }
          return OperationItem("$a - $b", a - b);

        case 2: // MULTIPLICACIÓ
          int a = random.nextInt(10) + 1; // 1-10
          int b = random.nextInt(10) + 1; // 1-10
          return OperationItem("$a × $b", a * b);

        case 3: // ✅ DIVISIÓ 100% 1-9 (MÀXIM 81÷9)
          int divisor = random.nextInt(9) + 1;   // 1-9
          int quotient = random.nextInt(9) + 1;  // 1-9
          int dividend = quotient * divisor;     // 1-81, sempre divisible
          return OperationItem("$dividend ÷ $divisor", quotient);

        default:
          int a = random.nextInt(10) + 1;
          int b = random.nextInt(10) + 1;
          return OperationItem("$a + $b", a + b);
      }
    });
    _operations.shuffle();
  }

  void _handleSelection(OperationItem item) {
    if (item.isSelected || _isGameOver) return;

    setState(() {
      item.isSelected = true;
      _userOrder.add(item);
    });

    if (_userOrder.length == _operations.length) {
      _checkResult();
    }
  }

  void _checkResult() {
    _isGameOver = true;
    List<OperationItem> correctOrder = List.from(_operations)
      ..sort((a, b) => a.result.compareTo(b.result));

    bool isCorrect = true;
    for (int i = 0; i < correctOrder.length; i++) {
      if (_userOrder[i].result != correctOrder[i].result) {
        isCorrect = false;
        break;
      }
    }

    _showResult(win: isCorrect);
  }

  void _showResult({required bool win}) {
    setState(() {
      _showResultPanel = true;
      _resultColor = win ? Colors.green : Colors.red;
      _resultTitle = win ? '🏆 Correcte!' : '❌ Incorrecte!';
      _resultMessage = win
          ? 'Has ordenat correctament totes les operacions!'
          : 'Revisa l\'ordre de menor a major i torna-ho a intentar.';
    });
  }

  void _resetGame() {
    setState(() {
      _userOrder.clear();
      _isGameOver = false;
      _showResultPanel = false;
      for (final op in _operations) {
        op.isSelected = false;
      }
      _generateOperations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Operacions', style: AppStyles.appBarText),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
            tooltip: "Reiniciar exercici",
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              "Calcula i ordena de menor a major:",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: IgnorePointer(
                ignoring: _isGameOver,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: _operations.length,
                  itemBuilder: (context, index) {
                    final op = _operations[index];
                    return InkWell(
                      onTap: op.isSelected || _isGameOver ? null : () => _handleSelection(op),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: op.isSelected
                              ? Colors.grey[300]
                              : Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: op.isSelected
                                ? Colors.grey
                                : Colors.blue.shade300,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          op.expression,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: op.isSelected
                                ? Colors.grey[600]
                                : Colors.blue[900],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (_showResultPanel)
            ResultPanel(
              title: _resultTitle,
              message: _resultMessage,
              color: _resultColor,
              onRestart: _resetGame,
            ),
        ],
      ),
    );
  }
}