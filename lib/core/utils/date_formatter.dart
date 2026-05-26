/// Render [date] as a human-friendly relative label.
///
/// Rules (matches the "Today, 2:15 PM" / "Yesterday" / "12 May" pattern used
/// on transaction tiles):
///
/// * Same calendar day as [now] → "Today"
/// * Previous calendar day → "Yesterday"
/// * Within the same year → "12 May"
/// * Earlier year → "12 May 2024"
///
/// [now] defaults to `DateTime.now()` — inject it in tests for determinism.
String formatRelativeDate(DateTime date, {DateTime? now}) {
  final DateTime today = _atMidnight(now ?? DateTime.now());
  final DateTime target = _atMidnight(date);
  final int dayDelta = today.difference(target).inDays;

  if (dayDelta == 0) return 'Today';
  if (dayDelta == 1) return 'Yesterday';

  final String day = date.day.toString();
  final String month = _monthShort[date.month - 1];

  if (date.year == today.year) return '$day $month';
  return '$day $month ${date.year}';
}

DateTime _atMidnight(DateTime d) => DateTime(d.year, d.month, d.day);

const List<String> _monthShort = <String>[
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
