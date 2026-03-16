import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/expense_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.expenses,
    required this.onRefresh,
    required this.onAddExpense,
    required this.onEditExpense,
    required this.onDeleteExpense,
  });

  final List<Expense> expenses;
  final VoidCallback onRefresh;
  final void Function(Expense) onAddExpense;
  final void Function(String, Expense) onEditExpense;
  final void Function(String) onDeleteExpense;

  double get _total => expenses.fold(0.0, (sum, e) => sum + e.amount);

  Color _getCategoryColor(String category) {
    return categoryColors[category.toLowerCase()] ?? categoryColors['other']!;
  }

  @override
  Widget build(BuildContext context) {
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
          ? _EmptyState(onAdd: () => Navigator.pushNamed(context, '/add'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _SummaryCard(total: _total, count: expenses.length),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => onRefresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses.reversed.toList()[index];
                        return _ExpenseTile(
                          expense: expense,
                          onTap: () => Navigator.pushNamed(context, '/detail', arguments: expense),
                          onEdit: () => Navigator.pushNamed(context, '/edit', arguments: expense),
                          onDelete: () => _showDeleteDialog(context, expense.id),
                        );
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

  void _showDeleteDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => _DeleteDialog(
        onConfirm: () {
          onDeleteExpense(id);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense deleted')),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.count,
  });

  final double total;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
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
              '$currencySymbol${total.toStringAsFixed(2)}',
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
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color get _color {
    return categoryColors[expense.category.toLowerCase()] ?? categoryColors['other']!;
  }

  String get _formattedDate {
    return '${expense.date.month}/${expense.date.day}/${expense.date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _color,
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
                  _formattedDate,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '$currencySymbol${expense.amount.toStringAsFixed(2)}',
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
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit, color: Colors.white70),
                title: Text('Edit', style: TextStyle(color: Colors.white)),
              ),
            ),
            PopupMenuItem(
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
}

class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
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
          onPressed: onConfirm,
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long, size: 80, color: Colors.white24),
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
            'Start tracking your expenses today!',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 250,
            child: FloatingActionButton.extended(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Expense'),
            ),
          ),
        ],
      ),
    );
  }
}

