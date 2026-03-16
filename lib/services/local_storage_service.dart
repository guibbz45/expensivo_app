import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/expense_model.dart';

class LocalStorageService {
  static const String _expensesKey = 'expenses';

  static Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = expenses.map((e) => e.toJson()).toList();
    await prefs.setString(_expensesKey, json.encode(jsonList));
  }

  static Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_expensesKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Expense.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_expensesKey);
  }
}

