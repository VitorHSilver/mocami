import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'models/expense_model.dart';
import 'services/calculation_service.dart';
import 'services/storage_service.dart';

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String input = '';
  List<Expense> expenses = [];
  Timer? _debounceTimer;
  final TextEditingController _textController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _onInputChanged(String value) {
    input = value;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        expenses = CalculationService.parseExpenses(input);
      });

      // Salvar automaticamente
      _saveData();
    });
  }

  // Salvar dados
  void _saveData() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await StorageService.saveLastInput(input);
      await StorageService.saveExpenses(expenses);
    } catch (e) {
      print('Erro ao salvar dados: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  double get total => CalculationService.calculateTotal(expenses);

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _loadData() async {
    try {
      final savedInput = await StorageService.loadLastInput();
      final savedExpenses = await StorageService.loadExpenses();

      setState(() {
        input = savedInput;
        expenses = savedExpenses;
        _textController.text = savedInput;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora Mocami'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Limpar lista de dados',
            onPressed: () async {
              setState(() {
                input = '';
                expenses = [];
                _textController.clear();
              });
              await StorageService.clearAll();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Dados limpos!')));
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Digite suas despesas (ex: Aluguel 500)',
                suffixIcon: _isSaving
                    ? Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              onChanged: (value) {
                _onInputChanged(value);
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(expenses[index].description),
                    trailing: Text(
                      expenses[index].value != null
                          ? expenses[index].value!.toStringAsFixed(2)
                          : '---',
                    ),
                  );
                },
              ),
            ),
            ListTile(
              title: Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                total.toStringAsFixed(2),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: total.toStringAsFixed(2)),
                );
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Total copiado!')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
