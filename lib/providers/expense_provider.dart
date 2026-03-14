import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadExpenses({int limit = 10}) async {
    _setLoading(true);
    try {
      _expenses = await _apiService.getExpenses(limit: limit);
      _error = null;
      
      // Seed sample data if no expenses from API
      if (_expenses.isEmpty) {
        _expenses = _getSampleExpenses();
      }
    } catch (e) {
      _error = e.toString();
      // Seed samples on error too for demo
      _expenses = _getSampleExpenses();
    } finally {
      _setLoading(false);
    }
  }

  List<Expense> _getSampleExpenses() {
    final now = DateTime.now();
    return [
      Expense(
        id: 'gas1',
        title: 'Gas',
        amount: 45.75,
        category: 'Gas',
        date: now.subtract(const Duration(days: 2)),
      ),
      Expense(
        id: 'movies1',
        title: 'Movies',
        amount: 250.00,
        category: 'movies',
        date: now.subtract(const Duration(days: 1)),
      ),
      Expense(
        id: 'apple1',
        title: 'Apple',
        amount: 15.50,
        category: 'apple',
        date: now,
      ),
    ];
  }

  Future<void> addExpense(Expense expense) async {
    _setLoading(true);
    try {
      final newExpense = await _apiService.createExpense(expense);
      _expenses.insert(0, newExpense); // Add to top
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateExpense(String id, Expense expense) async {
    _setLoading(true);
    try {
      final updatedExpense = await _apiService.updateExpense(id, expense);
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteExpense(String id) async {
    _setLoading(true);
    try {
      await _apiService.deleteExpense(id);
      _expenses.removeWhere((e) => e.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
