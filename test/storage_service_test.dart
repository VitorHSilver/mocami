import 'package:flutter_test/flutter_test.dart';
import 'package:mocami/services/storage_service.dart';
import 'package:mocami/models/expense_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('StorageService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('salvar e carregar expenses', () async {
      // Criar dados de teste
      List<Expense> expenses = [
        Expense(description: 'Aluguel', value: 800.0),
        Expense(description: 'Energia', value: 120.50),
        Expense(description: 'Sem valor'),
      ];

      // Salvar
      await StorageService.saveExpenses(expenses);

      // Carregar
      List<Expense> loadedExpenses = await StorageService.loadExpenses();

      // Verificar
      expect(loadedExpenses.length, equals(3));
      expect(loadedExpenses[0].description, equals('Aluguel'));
      expect(loadedExpenses[0].value, equals(800.0));
      expect(loadedExpenses[1].description, equals('Energia'));
      expect(loadedExpenses[1].value, equals(120.50));
      expect(loadedExpenses[2].description, equals('Sem valor'));
      expect(loadedExpenses[2].value, isNull);
    });

    test('salvar e carregar último input', () async {
      String input = 'Aluguel 800\nEnergia 120.50';

      // Salvar
      await StorageService.saveLastInput(input);

      // Carregar
      String loadedInput = await StorageService.loadLastInput();

      // Verificar
      expect(loadedInput, equals(input));
    });

    test('carregar dados vazios retorna valores padrão', () async {
      // Carregar sem ter salvado nada
      List<Expense> expenses = await StorageService.loadExpenses();
      String input = await StorageService.loadLastInput();

      // Verificar valores padrão
      expect(expenses, isEmpty);
      expect(input, isEmpty);
    });

    test('limpar todos os dados', () async {
      // Salvar alguns dados
      await StorageService.saveLastInput('Teste');
      await StorageService.saveExpenses([
        Expense(description: 'Teste', value: 100.0)
      ]);

      // Limpar
      await StorageService.clearAll();

      // Verificar se foi limpo
      String input = await StorageService.loadLastInput();
      List<Expense> expenses = await StorageService.loadExpenses();

      expect(input, isEmpty);
      expect(expenses, isEmpty);
    });
  });
}
