import 'package:flutter_test/flutter_test.dart';

double parseReceiptAmount(dynamic raw) {
  if (raw == null) return 0.0;
  if (raw is num) return raw.toDouble();
  if (raw is String) {
    String clean = raw.trim().replaceAll('Rp', '').replaceAll('rp', '').replaceAll('RP', '').trim();
    // Check if it has comma as decimal: e.g. "45.000,00"
    if (clean.contains('.') && clean.contains(',')) {
      clean = clean.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(clean) ?? 0.0;
    }
    // If it has only comma: e.g. "45,000" or "45000,00"
    if (clean.contains(',') && !clean.contains('.')) {
      final parts = clean.split(',');
      if (parts.length == 2 && parts[1].length == 3) {
        // Thousands separator e.g. 45,000
        clean = clean.replaceAll(',', '');
        return double.tryParse(clean) ?? 0.0;
      } else {
        // Decimal separator e.g. 45000,50
        clean = clean.replaceAll(',', '.');
        return double.tryParse(clean) ?? 0.0;
      }
    }
    // If it has dot e.g. "45.000"
    if (clean.contains('.')) {
      final parts = clean.split('.');
      if (parts.length == 2 && parts[1].length == 3) {
        // 45.000 is 45000 in IDR!
        clean = clean.replaceAll('.', '');
        return double.tryParse(clean) ?? 0.0;
      }
      if (parts.length > 2) {
        // 1.250.000
        clean = clean.replaceAll('.', '');
        return double.tryParse(clean) ?? 0.0;
      }
    }
    clean = clean.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }
  return 0.0;
}

void main() {
  test('parsing amounts', () {
    expect(parseReceiptAmount(45000), 45000.0);
    expect(parseReceiptAmount('45000'), 45000.0);
    expect(parseReceiptAmount('45.000'), 45000.0);
    expect(parseReceiptAmount('1.450.000'), 1450000.0);
    expect(parseReceiptAmount('Rp 45.000,00'), 45000.0);
    expect(parseReceiptAmount('Rp 45,000'), 45000.0);
  });
}
