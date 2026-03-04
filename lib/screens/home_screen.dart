import 'package:flutter/material.dart';
import '../Expenses.dart';

class HomeScreen extends StatelessWidget {
  final List<Expense> expenses;
  final Function(Expense) onAddExpense;
  final Function(String, Expense) onEditExpense;
  final Function(String) onDeleteExpense;

  const HomeScreen({
    super.key,
    required this.expenses,
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
          title: const Text('Delete Expense',
              style: TextStyle(color: Colors.white, fontSize: 20)),
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
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
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
    return '₱${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color(0xFFFF6B6B);
      case 'transport':
        return const Color(0xFF4ECDC4);
      case 'entertainment':
        return const Color(0xFFFFE66D);
      case 'health':
        return const Color(0xFF95E1D3);
      case 'shopping':
        return const Color(0xFFC7CEEA);
      case 'utilities':
        return const Color(0xFF657EEB);
      default:
        return const Color(0xFF1A3A52);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalExpenses =
        expenses.fold<double>(0, (sum, e) => sum + e.amount);

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
                      final expense = expenses[expenses.length - 1 - index];
                      final categoryColor =
                          _getCategoryColor(expense.category);

                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/detail',
                            arguments: expense,
                          );
                        },
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                        if (value == 'edit') {
                                          Navigator.pushNamed(
                                            context,
                                            '/edit',
                                            arguments: expense,
                                          );
                                        } else if (value == 'delete') {
                                          _showDeleteDialog(context, expense.id);
                                        } else if (value == 'view') {
                                          Navigator.pushNamed(
                                            context,
                                            '/detail',
                                            arguments: expense,
                                          );
                                        }
                                      },
                                      itemBuilder: (BuildContext context) => [
                                        PopupMenuItem(
                                          value: 'view',
                                          child: Row(
                                            children: const [
                                              Icon(Icons.visibility,
                                                  size: 18, color: Colors.white70),
                                              SizedBox(width: 8),
                                              Text('View',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: const [
                                              Icon(Icons.edit,
                                                  size: 18, color: Colors.white70),
                                              SizedBox(width: 8),
                                              Text('Edit',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: const [
                                              Icon(Icons.delete,
                                                  size: 18,
                                                  color: Color(0xFFFF6B6B)),
                                              SizedBox(width: 8),
                                              Text('Delete',
                                                  style: TextStyle(
                                                      color: Color(0xFFFF6B6B))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
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
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, '/add');
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Expense'),
          ),
        ],
      ),
    );
  }
}
