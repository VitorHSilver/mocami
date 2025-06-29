import '../models/expense_model.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculationService {
  static List<Expense> parseExpenses(String input) {
    return input
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map(_parseLine)
        .toList();
  }

  static double calculateTotal(List<Expense> expenses) {
    if (expenses.isEmpty) return 0.0;

    var validExpenses = expenses
        .where((expense) => expense.value != null)
        .map((expense) => expense.value!);

    if (validExpenses.isEmpty) return 0.0;
    return validExpenses.reduce((a, b) => a + b);
  }

  static double? evaluateExpression(String expression) {
    try {
      expression = expression.replaceAll(' ', '').replaceAll(',', '.');

      // ✅ HÍBRIDO: Para números simples, usar código próprio (mais rápido)
      if (RegExp(r'^\d+(\.\d+)?$').hasMatch(expression)) {
        return double.parse(expression);
      }

      // ✅ Para números negativos simples
      if (RegExp(r'^-\d+(\.\d+)?$').hasMatch(expression)) {
        return double.parse(expression);
      }

      // ✅ Para operações simples (2 números), usar código próprio
      if (_isSimpleOperation(expression)) {
        return _evaluateSimpleOperation(expression);
      }

      // ✅ Para expressões complexas, usar biblioteca math_expressions
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      return exp.evaluate(EvaluationType.REAL, cm);
    } catch (e) {
      return null;
    }
  }

  // Verifica se é uma operação simples (apenas 2 números e 1 operador)
  static bool _isSimpleOperation(String expression) {
    RegExp simplePattern = RegExp(r'^\d+(\.\d+)?[+\-*/]\d+(\.\d+)?$');
    return simplePattern.hasMatch(expression);
  }

  // Avalia operações simples com código próprio (mais rápido)
  static double? _evaluateSimpleOperation(String expression) {
    try {
      if (expression.contains('+')) {
        var parts = expression.split('+');
        return double.parse(parts[0]) + double.parse(parts[1]);
      } else if (expression.contains('*')) {
        var parts = expression.split('*');
        return double.parse(parts[0]) * double.parse(parts[1]);
      } else if (expression.contains('/')) {
        var parts = expression.split('/');
        double denominator = double.parse(parts[1]);
        if (denominator == 0) return null;
        return double.parse(parts[0]) / denominator;
      } else if (expression.contains('-')) {
        // Cuidado com números negativos
        int lastMinusIndex = expression.lastIndexOf('-');
        if (lastMinusIndex > 0) {
          String first = expression.substring(0, lastMinusIndex);
          String second = expression.substring(lastMinusIndex + 1);
          return double.parse(first) - double.parse(second);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Expense _parseLine(String line) {
    var parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      return Expense(description: line.trim());
    }

    String valueStr = parts.last;
    double? value = evaluateExpression(valueStr);
    String description = parts.sublist(0, parts.length - 1).join(' ');

    return Expense(description: description, value: value);
  }
}
