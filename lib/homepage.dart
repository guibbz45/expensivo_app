// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/expense_model.dart';
import 'providers/expense_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // ── Formatters ──────────────────────────────────────────────────────────────

  static String formatCurrency(double amount) =>
      '₱${amount.toStringAsFixed(2)}';

  static String formatDate(DateTime date) =>
      '${date.month}/${date.day}/${date.year}';

  static Color categoryColor(String category) {
    const map = {
      'apple': Color(0xFFFF6B6B),
      'gas': Color(0xFF4ECDC4),
      'movies': Color(0xFFFFE66D),
    };
    return map[category.toLowerCase()] ?? const Color(0xFF1A3A52);
  }

  
  void _goToEdit(BuildContext context, Expense expense) =>
      Navigator.pushNamed(context, '/edit', arguments: expense);

  void _goToDetail(BuildContext context, Expense expense) =>
      Navigator.pushNamed(context, '/detail', arguments: expense);

  void _goToAdd(BuildContext context) =>
      Navigator.pushNamed(context, '/add');

  

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const _LoadingView();
        if (provider.error != null) return _ErrorView(provider: provider);

        final expenses = provider.expenses;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushReplacementNamed(context, '/start'),
            ),
            title: const Text(
              'Expenses',
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
              ? _EmptyState(onAdd: () => _goToAdd(context))
              : _ExpenseList(
                  expenses: expenses,
                  onRefresh: () => provider.loadExpenses(limit: 10),
                  onTap: (e) => _goToDetail(context, e),
                  onEdit: (e) => _goToEdit(context, e),
                  onDelete: (id) => _showDeleteDialog(context, id),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _goToAdd(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
          ),
        );
      },
    );
  }

  

  void _showDeleteDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => _DeleteDialog(
        onConfirm: () {
          context.read<ExpenseProvider>().deleteExpense(id);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense deleted')),
          );
        },
      ),
    );
  }
}



class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF1A3A52)),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.provider});

  final ExpenseProvider provider;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red[300]),
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
            child: ElevatedButton.icon(
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

class _ExpenseList extends StatelessWidget {
  const _ExpenseList({
    required this.expenses,
    required this.onRefresh,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Expense> expenses;
  final Future<void> Function() onRefresh;
  final void Function(Expense) onTap;
  final void Function(Expense) onEdit;
  final void Function(String) onDelete;

  double get _total => expenses.fold(0, (sum, e) => sum + e.amount);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Column(
        children: [
          _SummaryCard(total: _total, count: expenses.length),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses.reversed.toList()[index];
                return _ExpenseCard(
                  expense: expense,
                  onTap: () => onTap(expense),
                  onEdit: () => onEdit(expense),
                  onDelete: () => onDelete(expense.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.total, required this.count});

  final double total;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
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
                HomePage.formatCurrency(total),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$count ${count == 1 ? 'expense' : 'expenses'}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.expense,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = HomePage.categoryColor(expense.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color,
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
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  HomePage.formatDate(expense.date),
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                Text(
                  HomePage.formatCurrency(expense.amount),
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
            switch (value) {
              case 'view':
                onTap();
                break;
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility, color: Colors.white70),
                title: Text('View', style: TextStyle(color: Colors.white)),
              ),
            ),
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
        'Are you sure?',
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