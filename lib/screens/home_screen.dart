import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../constants.dart';

class HomeScreen extends StatelessWidget {
  final List<Expense> expenses;
  final VoidCallback onRefresh; // New for refresh
  final Function(Expense) onAddExpense;
  final Function(String, Expense) onEditExpense;
  final Function(String) onDeleteExpense;

  const HomeScreen({
    super.key,
    required this.expenses,
    required this.onRefresh,
    required this.onAddExpense,
    required this.onEditExpense,
    required this.onDeleteExpense,
  });

  void _showDeleteDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Delete Expense',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
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
              onPressed: () {
                onDeleteExpense(id);
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

  String _formatCurrency(double amount) {
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Color _getCategoryColor(String category) {
    return categoryColors[category.toLowerCase()] ?? categoryColors['other']!;
  }

  Widget _buildTotalCard(double totalExpenses, int count) {
    return Card(
      color: const Color(0xFF0D1F2D),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              '$count ${count == 1 ? 'expense' : 'expenses'}',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTile(
    BuildContext context,
    Expense expense,
  ) {
    final categoryColor = _getCategoryColor(expense.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () => Navigator.pushNamed(context, '/detail', arguments: expense),
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
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                Navigator.pushNamed(context, '/edit', arguments: expense);
                break;
              case 'delete':
                _showDeleteDialog(context, expense.id);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit, color: Colors.white70),
                title: Text('Edit', style: TextStyle(color: Colors.white)),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Color(0xFFFF6B6B)),
                title: Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B))),
              ),
            ),
          ],
        ),
      ),
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
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 250,
            child: FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/add'),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Expense'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalExpenses = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);

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
      ),
      body: expenses.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildTotalCard(totalExpenses, expenses.length),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => onRefresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses.reversed.toList()[index];
                        return _buildExpenseTile(context, expense);
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}

