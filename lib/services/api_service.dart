import 'dart:math';
import '../models/expense_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final List<Expense> _store = [
    Expense(
      id: _uid(),
      title: 'Grocery Run',
      amount: 1250.75,
      category: 'Food',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Expense(
      id: _uid(),
      title: 'Shell Gas Station',
      amount: 2500.00,
      category: 'Gas',
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Expense(
      id: _uid(),
      title: 'Netflix Subscription',
      amount: 549.00,
      category: 'Entertainment',
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Expense(
      id: _uid(),
      title: 'iPhone Charger',
      amount: 1899.00,
      category: 'Apple',
      date: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Expense(
      id: _uid(),
      title: 'SM Cinema',
      amount: 420.00,
      category: 'Movies',
      date: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];


  Future<List<Expense>> getExpenses({int limit = 10}) async {
    await _fakeDelay();
    final result = _store.reversed.take(limit).toList();
    return List.unmodifiable(result);
  }



  Future<Expense> createExpense(Expense expense) async {
    await _fakeDelay();
    final created = Expense(
      id: _uid(),
      title: expense.title,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
    );
    _store.add(created);
    return created;
  }

  
  Future<Expense> updateExpense(String id, Expense expense) async {
    await _fakeDelay();
    final index = _store.indexWhere((e) => e.id == id);
    if (index == -1) throw Exception('Expense not found: $id');

    final updated = Expense(
      id: id,
      title: expense.title,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
    );
    _store[index] = updated;
    return updated;
  }

 
  Future<void> deleteExpense(String id) async {
    await _fakeDelay();
    _store.removeWhere((e) => e.id == id);
  }

 

  
  static Future<void> _fakeDelay() =>
      Future.delayed(Duration(milliseconds: 80 + Random().nextInt(120)));

  static String _uid() =>
      DateTime.now().microsecondsSinceEpoch.toString() +
      Random().nextInt(9999).toString().padLeft(4, '0');
}