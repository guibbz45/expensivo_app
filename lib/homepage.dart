// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/expense_model.dart';
import 'providers/expense_provider.dart';
import 'screens/add_edit_expense_screen.dart';
import 'screens/expense_detail_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _formatCurrency(double amount) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'apple':
        return const Color(0xFFFF6B6B);
      case 'gas':
        return const Color(0xFF4ECDC4);
      case 'movies':
        return const Color(0xFFFFE66D);
      default:
        return const Color(0xFF1A3A52);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1A3A52)),
            ),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error loading expenses',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: TextStyle(color: Colors.red[300]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        provider.clearError();
                        provider.loadExpenses(limit: 10);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final expenses = provider.expenses;
        final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Expensivo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            elevation: 4,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => provider.loadExpenses(limit: 10),
              ),
            ],
          ),
          body: expenses.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () => provider.loadExpenses(limit: 10),
                  child: Column(
                    children: [
                      // Total Expenses Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Card(
                          color: const Color(0xFF0D1F2D),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Expenses',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatCurrency(totalExpenses),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${expenses.length} ${expenses.length == 1 ? 'expense' : 'expenses'}',
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Expenses List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
final expense = provider.expenses[provider.expenses.length - 1 - index];
                            final categoryColor = _getCategoryColor(expense.category);

                            return GestureDetector(
                              onTap: () => _navigateToDetail(context, expense),
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: const Color(0xFF1E1E1E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    backgroundColor: categoryColor,
                                    radius: 28,
                                    child: Text(
                                      expense.category[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    expense.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        expense.category,
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDate(expense.date),
                                            style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 11,
                                            ),
                                          ),
                                          Text(
                                            _formatCurrency(expense.amount),
                                            style: const TextStyle(
                                              color: Color(0xFF4ECDC4),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    color: const Color(0xFF1E1E1E),
                                    onSelected: (value) {
                                      final prov = context.read<ExpenseProvider>();
                                      if (value == 'edit') {
                                        _navigateToEdit(context, expense);
                                      } else if (value == 'delete') {
                                        _showDeleteDialog(context, expense.id, prov);
                                      } else if (value == 'view') {
                                        _navigateToDetail(context, expense);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => [
                                      PopupMenuItem(
                                        value: 'view',
                                        child: const Row(
                                          children: [
                                            Icon(Icons.visibility, size: 18, color: Colors.white70),
                                            SizedBox(width: 8),
                                            Text('View', style: TextStyle(color: Colors.white)),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: const Row(
                                          children: [
                                            Icon(Icons.edit, size: 18, color: Colors.white70),
                                            SizedBox(width: 8),
                                            Text('Edit', style: TextStyle(color: Colors.white)),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: const Row(
                                          children: [
                                            Icon(Icons.delete, size: 18, color: Color(0xFFFF6B6B)),
                                            SizedBox(width: 8),
                                            Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _navigateToAdd(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
          ),
        );
      },
    );
  }

  void _navigateToAdd(BuildContext context) async {
    final provider = context.read<ExpenseProvider>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditExpenseScreen(
          onSave: (expense) => provider.addExpense(expense),
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, Expense expense) async {
    final provider = context.read<ExpenseProvider>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditExpenseScreen(
          expense: expense,
          onSave: (updatedExpense) => provider.updateExpense(expense.id, updatedExpense),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Expense expense) async {
    final provider = context.read<ExpenseProvider>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailScreen(
          expense: expense,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id, ExpenseProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Delete Expense', style: TextStyle(color: Colors.white, fontSize: 20)),
          content: const Text(
            'Are you sure you want to delete this expense?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await provider.deleteExpense(id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Expense deleted')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Expenses Yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start tracking your expenses today',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _navigateToAdd(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Expense'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A3A52),
            ),
          ),
        ],
      ),
    );
  }
}

