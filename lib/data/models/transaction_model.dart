enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? description;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.description,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    final rawDate = map['date'];
    if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate != null && rawDate.runtimeType.toString().contains('Timestamp')) {
      try {
        parsedDate = (rawDate as dynamic).toDate();
      } catch (_) {
        parsedDate = DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

    return TransactionModel(
      id: (map['id'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: map['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      category: (map['category'] ?? 'Lainnya') as String,
      date: parsedDate,
      description: map['description'] as String?,
    );
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    String? description,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }
}
