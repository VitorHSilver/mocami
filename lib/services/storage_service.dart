import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/expense_model.dart';

class StorageService {
  static const String _keyExpenses = 'mocami_expenses';
  static const String _keyLastInput = 'mocami_last_input';

  static Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(
      expenses.map((expense) => expense.toJson()).toList(),
    );
    await prefs.setString(_keyExpenses, jsonString);
  }


  static Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyExpenses);
    
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Expense.fromJson(json)).toList();
    }
    return [];
  }

  static Future<void> saveLastInput(String input) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastInput, input);
  }

 
  static Future<String> loadLastInput() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastInput) ?? '';
  }


  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyExpenses);
    await prefs.remove(_keyLastInput);
  }
}