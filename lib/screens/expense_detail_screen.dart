import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../screens/add_edit_expense_screen.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailScreen({
    super.key,
    required this.expense,
  });

  String _formatCurrency(double amount) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color(0xFF4ECDC4);
      case 'transportation':
        return const Color(0xFFFF6B6B);
      case 'entertainment':
        return const Color(0xFFFFE66D);
      case 'shopping':
        return const Color(0xFF96CEB4);
      case 'bills':
        return const Color(0xFFFFD93D);
      default:
        return const Color(0xFF1A3A52);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transportation':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt;
      default:
        return Icons.category;
    }
  }

  // ✅ Fixed: confirm before deleting, and handle context safely after async gap
  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Expense', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this expense? This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // ✅ Fixed: capture provider and messenger before async gap
    if (!context.mounted) return;
    final provider = context.read<ExpenseProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    await provider.deleteExpense(expense.id);

    navigator.pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Expense deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(expense.category);
    final categoryIcon = _getCategoryIcon(expense.category);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: categoryColor, width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    categoryIcon,
                    size: 60,
                    color: categoryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    expense.category,
                    style: TextStyle(
                      color: categoryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Amount
            Card(
              color: const Color(0xFF0D1F2D),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amount',
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCurrency(expense.amount),
                      style: const TextStyle(
                        color: Color(0xFF4ECDC4),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Details
            const Text(
              'Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailTile(Icons.label, 'Title', expense.title),
            _buildDetailTile(Icons.calendar_today, 'Date', _formatDate(expense.date)),
            _buildDetailTile(Icons.category, 'Category', expense.category),
            if (expense.description != null && expense.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(expense.description!),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    // ✅ Fixed: push AddEditExpenseScreen directly instead of named route
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditExpenseScreen(
                          expense: expense,
                          onSave: (updatedExpense) {
                            context.read<ExpenseProvider>().updateExpense(
                              expense.id,
                              updatedExpense,
                            );
                          },
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white, // ✅ Added: ensure icon/text visible on red
                    ),
                    onPressed: () => _confirmDelete(context), // ✅ Fixed: now shows confirm dialog
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1A3A52)),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}