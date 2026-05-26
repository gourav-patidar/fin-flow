import '../../../shared/models/transaction.dart';
import '../../../shared/models/transaction_category.dart';
import '../../../shared/models/transaction_type.dart';

/// Pure derivations from a transaction list. No Flutter imports — fully
/// unit-testable. The Dashboard BLoC calls these on every stream emission;
/// keep them O(n) or better.
class DashboardCalculations {
  const DashboardCalculations._();

  /// Sum of all signed amounts (income +, expense -).
  static double totalBalance(List<Transaction> all) {
    double sum = 0;
    for (final Transaction t in all) {
      sum += t.signedAmount;
    }
    return sum;
  }

  /// Total income strictly within the calendar month containing [reference].
  static double monthIncome(List<Transaction> all, DateTime reference) {
    return _sumInMonth(all, reference, TransactionType.income);
  }

  /// Total expense (returned as a positive number) strictly within the
  /// calendar month containing [reference].
  static double monthExpense(List<Transaction> all, DateTime reference) {
    return _sumInMonth(all, reference, TransactionType.expense);
  }

  /// Map of category → expense total this month. Categories with zero
  /// spend are omitted so chart code can iterate without filtering.
  static Map<TransactionCategory, double> categoryBreakdown(
    List<Transaction> all,
    DateTime reference,
  ) {
    final Map<TransactionCategory, double> out =
        <TransactionCategory, double>{};
    for (final Transaction t in all) {
      if (t.type != TransactionType.expense) continue;
      if (!_isSameMonth(t.date, reference)) continue;
      out[t.category] = (out[t.category] ?? 0) + t.amount;
    }
    return out;
  }

  /// Latest [n] transactions, newest first.
  static List<Transaction> recentTransactions(
    List<Transaction> all, {
    int n = 5,
  }) {
    final List<Transaction> sorted = List<Transaction>.of(all)
      ..sort((Transaction a, Transaction b) => b.date.compareTo(a.date));
    if (sorted.length <= n) return sorted;
    return sorted.sublist(0, n);
  }

  static double _sumInMonth(
    List<Transaction> all,
    DateTime reference,
    TransactionType type,
  ) {
    double sum = 0;
    for (final Transaction t in all) {
      if (t.type != type) continue;
      if (!_isSameMonth(t.date, reference)) continue;
      sum += t.amount;
    }
    return sum;
  }

  static bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
}
