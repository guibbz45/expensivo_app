import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadExpenses({int limit = 10, bool forceRefresh = false}) async {
    _setLoading(true);
    try {
      if (!forceRefresh) {
        _expenses = await LocalStorageService.loadExpenses();
        notifyListeners(); 
      }

      if (_expenses.isEmpty || forceRefresh) {
        final apiExpenses = await _apiService.getExpenses(limit: limit);

        if (apiExpenses.isNotEmpty) {
          _expenses = apiExpenses;
        } else if (_expenses.isEmpty) {
          _expenses = _getSampleExpenses();
        }

        await LocalStorageService.saveExpenses(_expenses);
        notifyListeners(); 
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      if (_expenses.isEmpty) {
        _expenses = _getSampleExpenses();
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  List<Expense> _getSampleExpenses() {
    final now = DateTime.now();
    return [
      Expense(
        id: 'transport1',
        title: 'Gas',
        amount: 45.75,
        category: 'Transportation', 
        date: now.subtract(const Duration(days: 2)),
      ),
      Expense(
        id: 'entertainment1',
        title: 'Movies',
        amount: 250.00,
        category: 'Entertainment',
        date: now.subtract(const Duration(days: 1)),
      ),
      Expense(
        id: 'food1',
        title: 'Apple',
        amount: 15.50,
        category: 'Food', 
        date: now,
      ),
    ];
  }

  Future<void> addExpense(Expense expense) async {
    _setLoading(true);
    try {
      final newExpense = await _apiService.createExpense(expense);
      _expenses.insert(0, newExpense);
      await LocalStorageService.saveExpenses(_expenses);
      _error = null;
      notifyListeners(); 
    } catch (e) {
      _error = e.toString();
      _expenses.insert(0, expense);
      await LocalStorageService.saveExpenses(_expenses);
      notifyListeners();
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
      await LocalStorageService.saveExpenses(_expenses);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _expenses[index] = expense;
        await LocalStorageService.saveExpenses(_expenses);
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteExpense(String id) async {
    final index = _expenses.indexWhere((e) => e.id == id);
    final backup = index != -1 ? _expenses[index] : null;
    if (index != -1) {
      _expenses.removeAt(index);
      notifyListeners();
    }

    _setLoading(true);
    try {
      await _apiService.deleteExpense(id);
      await LocalStorageService.saveExpenses(_expenses);
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (backup != null && index != -1) {
        _expenses.insert(index, backup);
        notifyListeners();
      }
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