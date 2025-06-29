import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'models/expense_model.dart';
import 'services/calculation_service.dart';

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String input = '';
  List<Expense> expenses = [];
  Timer? _debounceTimer;

  void _onInputChanged(String value) {
    input = value;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        expenses = CalculationService.parseExpenses(input);
      });
    });
  }

  double get total => CalculationService.calculateTotal(expenses);

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calculadora Mocami')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Digite suas despesas (ex: Aluguel 500)',
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
