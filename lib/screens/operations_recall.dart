import 'package:flutter/material.dart';
import 'dart:math';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import '../widgets/result_panel.dart';

class OperationModel {
  final String expression;
  final int result;
  bool isSelected;

  OperationModel({
    required this.expression,
    required this.result,
    this.isSelected = false,
  });
}

class OperationsRecall extends StatefulWidget {
  final GameConfig config;
  final String language;

  const OperationsRecall({
    Key? key,
    required this.config,
    required this.language,
  }) : super(key: key);

  @override
  State<OperationsRecall> createState() => _OperationsRecallState();
}

class _OperationsRecallState extends State<OperationsRecall> {
  List<OperationModel> _operations = [];
  List<OperationModel> _userSelection = [];

  bool _showResultPanel = false;
  String _resultTitle = '';
  String _resultMessage = '';
  Color _resultColor = Colors.green;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    setState(() {
      _operations.clear();
      _userSelection.clear();
      _showResultPanel = false;
      _isGameOver = false;

      // Nombre d'operacions segons el nivell (rows del config)
      int count;
      if (widget.config.rows <= 2) {
        count = 2; // Fàcil
      } else if (widget.config.rows <= 4) {
        count = 4; // Mitjà
      } else {
        count = 6; // Difícil
      }

      final random = Random();

      while (_operations.length < count) {
        int n1 = random.nextInt(10) + 1;
        int n2 = random.nextInt(10) + 1;
        int res;
        String sym;

        if (random.nextBool()) {
          sym = '+';
          res = n1 + n2;
        } else {
          sym = '-';
          if (n1 < n2) {
            final temp = n1;
            n1 = n2;
            n2 = temp;
          }
          res = n1 - n2;
        }

        // Evitar resultats duplicats
        if (!_operations.any((e) => e.result == res)) {
          _operations.add(
            OperationModel(
              expression: '$n1 $sym $n2',
              result: res,
            ),
          );
        }
      }
      _operations.shuffle();
    });
  }

  void _handleSelection(OperationModel op) {
    if (op.isSelected || _isGameOver) return;

    setState(() {
      op.isSelected = true;
      _userSelection.add(op);

      if (_userSelection.length == _operations.length) {
        _checkResult();
      }
    });
  }

  void _checkResult() {
    List<OperationModel> sorted = List.from(_operations);
    sorted.sort((a, b) => a.result.compareTo(b.result));

    bool win = true;
    for (int i = 0; i < sorted.length; i++) {
      if (_userSelection[i].result != sorted[i].result) {
        win = false;
        break;
      }
    }

    setState(() {
      _isGameOver = true;
      _showResultPanel = true;
      _resultColor = win ? Colors.green : Colors.red;

      if (win) {
        _resultTitle = widget.language == 'cat'
            ? '🎉 Molt bé!'
            : widget.language == 'esp'
                ? '🎉 ¡Muy bien!'
                : '🎉 Well done!';
        _resultMessage = widget.language == 'cat'
            ? 'Has ordenat correctament!'
            : widget.language == 'esp'
                ? '¡Ordenado correctamente!'
                : 'Correctly sorted!';
      }
      else {
        _resultTitle = widget.language == 'cat'
            ? '❌ Error'
            : widget.language == 'esp'
                ? '❌ Error'
                : '❌ Error';
        _resultMessage = widget.language == 'cat'
            ? 'L\'ordre no era correcte.'
            : widget.language == 'esp'
                ? 'El orden no era correcto.'
                : 'The order was incorrect.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String instruction = widget.language == 'cat'
        ? 'Ordena de menor a major:' : widget.language == 'esp' ? 'Ordena de menor a mayor:' : 'Sort in ascending:';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Operacions',
          style: AppStyles.appBarText,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeGame,
          ),
        ],
      ),
      body: Column(
        children: [
          AppStyles.sizedBoxHeight20,
          Container(
            padding: const EdgeInsets.all(20.0),
            width: double.infinity,
            color: Colors.blue.shade50,
            child: Text(
              instruction,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _operations.length <= 2 ? 1 : 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: _operations.length <= 2 ? 2.5 : 1.8,
                ),
                itemCount: _operations.length,
                itemBuilder: (context, index) {
                  final op = _operations[index];
                  return GestureDetector(
                    onTap: () => _handleSelection(op),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: op.isSelected
                            ? Colors.blue.withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: op.isSelected
                              ? Colors.blue
                              : Colors.grey.shade300,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          op.expression,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: op.isSelected
                                ? Colors.blue
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          if (_showResultPanel)
            ResultPanel(
              title: _resultTitle,
              message: _resultMessage,
              color: _resultColor,
              onRestart: _initializeGame,
              language: widget.language,
            ),
        ],
      ),
    );
  }
}
