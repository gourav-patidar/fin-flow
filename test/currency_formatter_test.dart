import 'package:flutter_test/flutter_test.dart';

import 'package:finflow/core/utils/currency_formatter.dart';

void main() {
  group('formatINR', () {
    test('formats zero', () {
      expect(formatINR(0), '₹0');
    });

    test('formats small two-digit value', () {
      expect(formatINR(99), '₹99');
    });

    test('formats exactly one thousand with single group break', () {
      expect(formatINR(1000), '₹1,000');
    });

    test('formats one lakh with Indian grouping (1,00,000 not 100,000)', () {
      expect(formatINR(100000), '₹1,00,000');
    });

    test('formats large value with multiple Indian groups', () {
      expect(formatINR(12345678), '₹1,23,45,678');
    });

    test('formats negative value with leading sign', () {
      expect(formatINR(-500), '-₹500');
    });

    test('hides symbol when showSymbol is false', () {
      expect(formatINR(1500, showSymbol: false), '1,500');
    });

    test('includes decimals when requested', () {
      expect(formatINR(284650.20, decimals: 2), '₹2,84,650.20');
    });

    test('rounds at the truncation boundary correctly for negatives', () {
      expect(formatINR(-1234.50, decimals: 2), '-₹1,234.50');
    });

    test('999 stays ungrouped', () {
      expect(formatINR(999), '₹999');
    });
  });
}
