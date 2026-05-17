import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense_model.dart';



class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _collection = 'expenses';

  Future<List<Expense>> getExpenses({int limit = 10}) async {
    final snapshot = await _db
        .collection(_collection)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final id = (data['id'] ?? doc.id).toString();
      final rawAmount = data['amount'];
      final double amount = () {
        if (rawAmount == null) return 0.0;
        if (rawAmount is num) return rawAmount.toDouble();
        if (rawAmount is String) return double.tryParse(rawAmount) ?? 0.0;
        return 0.0;
      }();

      final rawCategory = (data['category'] ?? '');
      final category = (rawCategory is String ? rawCategory : rawCategory.toString()).trim();

      return Expense(
        id: id,
        title: (data['title'] ?? '') as String,
        amount: amount,
        category: category.isEmpty ? 'Other' : category,
        date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        description: data['description'] as String?,
      );
    }).toList(growable: false);
  }

  Future<Expense> createExpense(Expense expense) async {
    final docRef = _db.collection(_collection).doc(expense.id);

    await docRef.set({
      'id': expense.id,
      'title': expense.title,
      'amount': expense.amount,
      'category': expense.category,
      'date': Timestamp.fromDate(expense.date),
      'description': expense.description,
    });

    return expense;
  }

  Future<Expense> updateExpense(String id, Expense expense) async {
    final docRef = _db.collection(_collection).doc(id);

    final doc = await docRef.get();
    if (!doc.exists) {
      throw Exception('Expense not found: $id');
    }

    final updated = Expense(
      id: id,
      title: expense.title,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      description: expense.description,
    );

    await docRef.update({
      'title': updated.title,
      'amount': updated.amount,
      'category': updated.category,
      'date': Timestamp.fromDate(updated.date),
      'description': updated.description,
    });

    return updated;
  }

  Future<void> deleteExpense(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}

