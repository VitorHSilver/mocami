import 'package:flutter_test/flutter_test.dart';
import 'package:mocami/services/calculation_service.dart';

void main() {
  group('CalculationService - Versão Híbrida', () {
    test('Números simples (código próprio - rápido)', () {
      expect(CalculationService.evaluateExpression('123'), equals(123.0));
      expect(CalculationService.evaluateExpression('45.67'), equals(45.67));
      expect(CalculationService.evaluateExpression('-50'), equals(-50.0));
    });

    test('Operações simples (código próprio - rápido)', () {
      expect(CalculationService.evaluateExpression('10+5'), equals(15.0));
      expect(CalculationService.evaluateExpression('20-8'), equals(12.0));
      expect(CalculationService.evaluateExpression('6*7'), equals(42.0));
      expect(CalculationService.evaluateExpression('100/4'), equals(25.0));
    });

    test('Expressões complexas (biblioteca math_expressions)', () {
      // Múltiplas operações
      expect(CalculationService.evaluateExpression('10+5-2'), equals(13.0));
      expect(
        CalculationService.evaluateExpression('2+3*4'),
        equals(14.0),
      ); // Precedência

      // Parênteses
      expect(CalculationService.evaluateExpression('(10+5)*2'), equals(30.0));
      expect(CalculationService.evaluateExpression('2*(3+4)'), equals(14.0));

      // Expressões mais complexas
      expect(
        CalculationService.evaluateExpression('100/4+50-10'),
        equals(65.0),
      );
    });

    test('Casos de erro', () {
      expect(CalculationService.evaluateExpression('abc'), isNull);
      expect(CalculationService.evaluateExpression('10/0'), isNull);
      expect(CalculationService.evaluateExpression(''), isNull);
      expect(
        CalculationService.evaluateExpression('10**5'),
        isNull,
      ); // Operador inválido
    });

    test('Formatação de entrada', () {
      expect(
        CalculationService.evaluateExpression('10,5'),
        equals(10.5),
      ); // Vírgula → Ponto
      expect(
        CalculationService.evaluateExpression(' 10 + 5 '),
        equals(15.0),
      ); // Espaços
    });
  });
}
