import 'package:flutter_test/flutter_test.dart';
import 'package:quiz/data/models/receipt_scan_model.dart';

void main() {
  test('test receipt scan parsing with various formats', () {
    // Format 1: integer totalAmount
    final m1 = ReceiptScanModel.fromJson({
      'merchant': 'Indomaret Point',
      'totalAmount': 45000,
      'date': '2026-10-21',
      'category': 'Makanan & Minuman',
      'items': ['Kopi', 'Roti'],
      'notes': 'Struk sarapan'
    });
    expect(m1.totalAmount, 45000.0);
    expect(m1.category, 'Makanan & Minuman');

    // Format 2: string total_amount with "Rp 45.000,00"
    final m2 = ReceiptScanModel.fromJson({
      'store': 'Alfamart',
      'total_amount': 'Rp 45.000,00',
      'category': 'Belanja',
    });
    print('m2 totalAmount: ${m2.totalAmount}');
    expect(m2.totalAmount, 45000.0);

    // Format 3: string with "45.000"
    final m3 = ReceiptScanModel.fromJson({
      'total': '45.000',
    });
    print('m3 totalAmount: ${m3.totalAmount}');

    // Format 4: string with "Rp 150000"
    final m4 = ReceiptScanModel.fromJson({
      'totalAmount': 'Rp 150000',
    });
    print('m4 totalAmount: ${m4.totalAmount}');

    // Format 5: double 45000.0
    final m5 = ReceiptScanModel.fromJson({
      'totalAmount': 45000.0,
    });
    print('m5 totalAmount: ${m5.totalAmount}');
  });
}
