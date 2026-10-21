import '../../core/constants/app_constants.dart';

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
    // Parse amount safely across various possible keys
    double parsedAmount = 0.0;
    final rawAmount = json['totalAmount'] ??
        json['total_amount'] ??
        json['total'] ??
        json['grandTotal'] ??
        json['grand_total'] ??
        json['amount'] ??
        json['totalBayar'] ??
        json['total_bayar'];

    if (rawAmount is num) {
      parsedAmount = rawAmount.toDouble();
    } else if (rawAmount is String) {
      parsedAmount = _parseAmountString(rawAmount);
    }

    // Parse date safely
    DateTime? parsedDate;
    final rawDate = json['date'] ?? json['tanggal'] ?? json['transDate'];
    if (rawDate is String && rawDate.isNotEmpty) {
      parsedDate = DateTime.tryParse(rawDate);
    }

    // Parse items
    List<String> parsedItems = [];
    final rawItems = json['items'] ?? json['item'] ?? json['daftar_barang'] ?? json['products'];
    if (rawItems is List) {
      parsedItems = rawItems.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }

    // Parse merchant
    final rawMerchant = json['merchant'] ??
        json['merchant_name'] ??
        json['store'] ??
        json['toko'] ??
        json['nama_toko'] ??
        json['place'];
    final merchant = (rawMerchant?.toString().trim().isNotEmpty == true)
        ? rawMerchant.toString().trim()
        : 'Struk Belanja';

    // Parse category and normalize to AppConstants.expenseCategories
    final rawCategory = (json['category'] ?? json['kategori'] ?? '').toString();
    final normalizedCategory = normalizeExpenseCategory(rawCategory);

    final rawNotes = json['notes'] ?? json['catatan'] ?? json['keterangan'] ?? '';

    return ReceiptScanModel(
      merchant: merchant,
      totalAmount: parsedAmount,
      date: parsedDate ?? DateTime.now(),
      category: normalizedCategory,
      items: parsedItems,
      notes: rawNotes.toString().trim(),
    );
  }

  static double _parseAmountString(String raw) {
    var clean = raw.trim();
    // Remove "Rp", "IDR", and whitespace
    clean = clean.replaceAll(RegExp(r'rp|idr', caseSensitive: false), '').trim();

    // Check if ends with cents like ,00 or .00
    if (RegExp(r'[,.]\d{2}$').hasMatch(clean)) {
      clean = clean.substring(0, clean.length - 3);
    }

    // Strip everything except digits
    final onlyDigits = clean.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(onlyDigits) ?? 0.0;
  }

  static String normalizeExpenseCategory(String raw) {
    final lower = raw.toLowerCase().trim();

    if (lower.contains('makan') ||
        lower.contains('minum') ||
        lower.contains('resto') ||
        lower.contains('kopi') ||
        lower.contains('cafe') ||
        lower.contains('food') ||
        lower.contains('beverage') ||
        lower.contains('kuliner')) {
      return 'Makanan & Minuman';
    }

    if (lower.contains('transport') ||
        lower.contains('bensin') ||
        lower.contains('bbm') ||
        lower.contains('ojek') ||
        lower.contains('grab') ||
        lower.contains('gojek') ||
        lower.contains('parkir') ||
        lower.contains('tol') ||
        lower.contains('taksi') ||
        lower.contains('kereta') ||
        lower.contains('bus')) {
      return 'Transportasi';
    }

    if (lower.contains('tagihan') ||
        lower.contains('listrik') ||
        lower.contains('pln') ||
        lower.contains('air') ||
        lower.contains('pdam') ||
        lower.contains('pulsa') ||
        lower.contains('kuota') ||
        lower.contains('internet') ||
        lower.contains('wifi') ||
        lower.contains('bpjs') ||
        lower.contains('sewa')) {
      return 'Tagihan';
    }

    if (lower.contains('hiburan') ||
        lower.contains('nonton') ||
        lower.contains('bioskop') ||
        lower.contains('cinema') ||
        lower.contains('game') ||
        lower.contains('wisata') ||
        lower.contains('rekreasi')) {
      return 'Hiburan';
    }

    if (lower.contains('sehat') ||
        lower.contains('obat') ||
        lower.contains('apotek') ||
        lower.contains('dokter') ||
        lower.contains('klinik') ||
        lower.contains('medis') ||
        lower.contains('rs') ||
        lower.contains('rumah sakit')) {
      return 'Kesehatan';
    }

    if (lower.contains('didik') ||
        lower.contains('sekolah') ||
        lower.contains('kuliah') ||
        lower.contains('kursus') ||
        lower.contains('buku') ||
        lower.contains('les')) {
      return 'Pendidikan';
    }

    if (lower.contains('belanja') ||
        lower.contains('mart') ||
        lower.contains('supermarket') ||
        lower.contains('minimarket') ||
        lower.contains('indomaret') ||
        lower.contains('alfamart') ||
        lower.contains('mall') ||
        lower.contains('toko') ||
        lower.contains('pasar') ||
        lower.contains('shopping')) {
      return 'Belanja';
    }

    // Direct match check
    for (final cat in AppConstants.expenseCategories) {
      if (cat.toLowerCase() == lower) {
        return cat;
      }
    }

    return 'Belanja';
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
