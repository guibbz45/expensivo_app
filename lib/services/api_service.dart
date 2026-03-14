import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/expense_model.dart';

class ApiService {
  static const String _expensesEndpoint = '/todos';

  Future<List<Expense>> getExpenses({int limit = 10}) async {
    final url = Uri.parse('$apiBaseUrl$_expensesEndpoint?_limit=$limit');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Expense.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load expenses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Expense> createExpense(Expense expense) async {
    final url = Uri.parse('$apiBaseUrl$_expensesEndpoint');
    try {
      // Simplify for mock: send only title, completed false
      final body = json.encode({
        'title': expense.title,
        'completed': false,
      });
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Expense.fromJson(data);
      } else {
        throw Exception('Failed to create expense: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Expense> updateExpense(String id, Expense expense) async {
    final url = Uri.parse('$apiBaseUrl$_expensesEndpoint/$id');
    try {
      final body = json.encode({
        'title': expense.title,
        'completed': false,
      });
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Expense.fromJson(data);
      } else {
        throw Exception('Failed to update expense: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteExpense(String id) async {
    final url = Uri.parse('$apiBaseUrl$_expensesEndpoint/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete expense: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

