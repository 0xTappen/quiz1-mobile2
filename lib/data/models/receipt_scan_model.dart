class ReceiptScanModel {
  final String merchant;
  final double totalAmount;
  final DateTime? date;
  final String category;
  final List<String> items;
  final String notes;

  const ReceiptScanModel({
    required this.merchant,
    required this.totalAmount,
    this.date,
    required this.category,
    this.items = const [],
    this.notes = '',
  });

  factory ReceiptScanModel.fromJson(Map<String, dynamic> json) {
    // Parse amount safely
    double parsedAmount = 0.0;
    final rawAmount = json['totalAmount'];
    if (rawAmount is num) {
      parsedAmount = rawAmount.toDouble();
    } else if (rawAmount is String) {
      final clean = rawAmount.replaceAll(RegExp(r'[^0-9.]'), '');
      parsedAmount = double.tryParse(clean) ?? 0.0;
    }

    // Parse date safely
    DateTime? parsedDate;
    final rawDate = json['date'];
    if (rawDate is String && rawDate.isNotEmpty) {
      parsedDate = DateTime.tryParse(rawDate);
    }

    // Parse items
    List<String> parsedItems = [];
    final rawItems = json['items'];
    if (rawItems is List) {
      parsedItems = rawItems.map((e) => e.toString()).toList();
    }

    return ReceiptScanModel(
      merchant: json['merchant']?.toString().trim() ?? 'Struk Belanja',
      totalAmount: parsedAmount,
      date: parsedDate ?? DateTime.now(),
      category: json['category']?.toString().trim() ?? 'Belanja',
      items: parsedItems,
      notes: json['notes']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'merchant': merchant,
        'totalAmount': totalAmount,
        'date': date?.toIso8601String(),
        'category': category,
        'items': items,
        'notes': notes,
      };
}
