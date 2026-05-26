import 'package:flutter_test/flutter_test.dart';

import 'package:finflow/core/utils/date_formatter.dart';

void main() {
  group('formatRelativeDate', () {
    final DateTime now = DateTime(2026, 5, 26, 14, 30);

    test('returns "Today" for the same calendar day', () {
      expect(formatRelativeDate(DateTime(2026, 5, 26, 9, 0), now: now), 'Today');
    });

    test('returns "Today" even just past midnight', () {
      expect(formatRelativeDate(DateTime(2026, 5, 26, 0, 5), now: now), 'Today');
    });

    test('returns "Yesterday" for one calendar day earlier', () {
      expect(formatRelativeDate(DateTime(2026, 5, 25, 23, 0), now: now),
          'Yesterday');
    });

    test('returns "D Mon" for same-year past dates', () {
      expect(formatRelativeDate(DateTime(2026, 1, 12), now: now), '12 Jan');
    });

    test('returns "D Mon YYYY" for earlier years', () {
      expect(formatRelativeDate(DateTime(2024, 5, 12), now: now), '12 May 2024');
    });

    test('handles single-digit days without leading zero', () {
      expect(formatRelativeDate(DateTime(2026, 3, 5), now: now), '5 Mar');
    });

    test('treats tomorrow as a future date (not Today)', () {
      // Future dates: we just render as date — covers seed/test data quirks.
      expect(formatRelativeDate(DateTime(2026, 5, 27), now: now), '27 May');
    });
  });
}
