class BudgetModel {
  final String id;
  final String name;
  final double amount;
  final String category;

  const BudgetModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'amount': amount, 'category': category};
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
    );
  }

  BudgetModel copyWith({
    String? id,
    String? name,
    double? amount,
    String? category,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
    );
  }
}
