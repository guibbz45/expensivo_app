class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? description;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
  });

  // Copy with method for editing
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'description': description,
  };

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 1.0, // Default for mock
      category: json['category'] ?? 'Other',
      date: DateTime.tryParse(json['date'] ?? DateTime.now().toIso8601String()) ?? DateTime.now(),
      description: json['description'],
    );
  }

  @override
  String toString() =>
      'Expense(id: $id, title: $title, amount: $amount, category: $category, date: $date)';
}
