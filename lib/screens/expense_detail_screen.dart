import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import 'add_edit_expense_screen.dart';

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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'apple':
        return Icons.phone_iphone;
      case 'gas':
        return Icons.local_gas_station;
      case 'movies':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(expense.category);
    final categoryIcon = _getCategoryIcon(expense.category);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Badge
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.2),
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

            // Amount Section
            Card(
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
                      'Amount',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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

            // Details Section
            const Text(
              'Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildDetailRow(Icons.label, 'Title', expense.title),
            const SizedBox(height: 12),

            _buildDetailRow(Icons.calendar_today, 'Date', _formatDate(expense.date)),
            const SizedBox(height: 12),

            _buildDetailRow(Icons.category, 'Category', expense.category),

            if (expense.description != null && expense.description!.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Description',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF1A3A52),
                    width: 1,
                  ),
                ),
                child: Text(
                  expense.description!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3A52),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      final provider = context.read<ExpenseProvider>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditExpenseScreen(
                            expense: expense,
                            onSave: (updated) => provider.updateExpense(expense.id, updated),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      final provider = context.read<ExpenseProvider>();
                      provider.deleteExpense(expense.id);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Expense deleted')),
                      );
                    },
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF1A3A52),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1A3A52), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

