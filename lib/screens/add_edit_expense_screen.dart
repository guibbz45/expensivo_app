import 'package:flutter/material.dart';
import '../models/expense_model.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;
  final void Function(Expense) onSave;

  const AddEditExpenseScreen({
    super.key,
    this.expense,
    required this.onSave,
  });

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _selectedCategory;
  bool _isSaving = false;

final List<String> categories = [
    'apple',
    'Gas',
    'movies'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController = TextEditingController(text: widget.expense!.title);
      _amountController = TextEditingController(text: widget.expense!.amount.toString());
      _descriptionController = TextEditingController(text: widget.expense!.description ?? '');
      _selectedDate = widget.expense!.date;
      _selectedCategory = widget.expense!.category;
    } else {
      _titleController = TextEditingController();
      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDate = DateTime.now();
      _selectedCategory = 'apple';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1A3A52),
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all required fields')),
        );
      }
      return;
    }

    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final expense = Expense(
      id: widget.expense?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
    );

    widget.onSave(expense);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.expense != null ? 'Expense updated' : 'Expense added',
          ),
        ),
      );
    }

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.expense != null ? 'Edit Expense' : 'Add Expense',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Title',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Grocery Shopping',
                      prefixIcon: const Icon(Icons.shopping_cart, color: Colors.white54),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Amount',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.attach_money, color: Colors.white54),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Category',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      border: Border.all(color: const Color(0xFF1A3A52), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: const Color(0xFF1E1E1E),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      items: categories.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Date',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        border: Border.all(color: const Color(0xFF1A3A52), width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.white54, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Description (Optional)',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Add any notes...',
                      prefixIcon: const Icon(Icons.description, color: Colors.white54),
                    ),
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3A52),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _saveExpense,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              widget.expense != null ? 'Update Expense' : 'Add Expense',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}

