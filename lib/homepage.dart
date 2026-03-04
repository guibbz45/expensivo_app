import 'package:flutter/material.dart';
import 'Expenses.dart';
import 'screens/add_edit_expense_screen.dart';
import 'screens/expense_detail_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Sample expenses list
  late List<Expense> expenses;

  @override
  void initState() {
    super.initState();
    expenses = [
      Expense(
        id: '1',
        title: 'Groceries',
        amount: 45.50,
        category: 'Food',
        date: DateTime.now().subtract(const Duration(days: 2)),
        description: 'Weekly grocery shopping',
      ),
      Expense(
        id: '2',
        title: 'Gas',
        amount: 60.00,
        category: 'Transport',
        date: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Fill up gas tank',
      ),
      Expense(
        id: '3',
        title: 'Movie Tickets',
        amount: 30.00,
        category: 'Entertainment',
        date: DateTime.now(),
        description: 'Double movie with friends',
      ),
    ];
  }

  void _addExpense(Expense expense) {
    setState(() {
      expenses.add(expense);
    });
  }

  void _editExpense(String id, Expense updatedExpense) {
    setState(() {
      final index = expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        expenses[index] = updatedExpense;
      }
    });
  }

  void _deleteExpense(String id) {
    setState(() {
      expenses.removeWhere((e) => e.id == id);
    });
  }

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
                _deleteExpense(id);
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

    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
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
                            _navigateToDetailExpense(context, expense);
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
                                    _navigateToEditExpense(context, expense);
                                  } else if (value == 'delete') {
                                    _showDeleteDialog(context, expense.id);
                                  } else if (value == 'view') {
                                    _navigateToDetailExpense(context, expense);
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
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _navigateToAddExpense(context);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Expense'),
        ),
      ),
    );
  }

  void _navigateToAddExpense(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditExpenseScreen(
          onSave: _addExpense,
        ),
      ),
    );
    if (result != null) {
      setState(() {});
    }
  }

  void _navigateToDetailExpense(BuildContext context, Expense expense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailScreen(
          expense: expense,
          onEdit: (updated) => _editExpense(expense.id, updated),
          onDelete: () => _deleteExpense(expense.id),
        ),
      ),
    );
    if (result != null) {
      setState(() {});
    }
  }

  void _navigateToEditExpense(BuildContext context, Expense expense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditExpenseScreen(
          expense: expense,
          onSave: (updatedExpense) =>
              _editExpense(expense.id, updatedExpense),
        ),
      ),
    );
    if (result != null) {
      setState(() {});
    }
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
              _navigateToAddExpense(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Expense'),
          ),
        ],
      ),
    );
  }
}