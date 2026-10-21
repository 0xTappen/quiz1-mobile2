import 'package:flutter_test/flutter_test.dart';
import 'package:quiz/core/utils/currency_formatter.dart';

void main() {
  test('Test CurrencyFormatter', () {
    const double val = 45000.0;
    final formatted = CurrencyFormatter.format(val);
    print('formatted: "$formatted"');
    final replaced = formatted.replaceAll('Rp ', '');
    print('replaced: "$replaced"');
    final parsed = CurrencyFormatter.parse(replaced);
    print('parsed: $parsed');
    expect(parsed, 45000.0);
  });
}
