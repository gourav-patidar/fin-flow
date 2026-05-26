import '../../../shared/models/transaction.dart';
import '../../../shared/models/transaction_category.dart';
import '../../../shared/models/transaction_type.dart';

// ─── Filter chip union ────────────────────────────────────────────────────────

sealed class TxChipFilter {
  const TxChipFilter();

  String get label => switch (this) {
        TxChipAll() => 'All',
        TxChipByType(:final type) => type.isIncome ? 'Income' : 'Expense',
        TxChipByCategory(:final category) => category.label,
      };
}

final class TxChipAll extends TxChipFilter {
  const TxChipAll();

  @override
  bool operator ==(Object other) => other is TxChipAll;

  @override
  int get hashCode => 0;
}

final class TxChipByType extends TxChipFilter {
  const TxChipByType(this.type);
  final TransactionType type;

  @override
  bool operator ==(Object other) =>
      other is TxChipByType && other.type == type;

  @override
  int get hashCode => type.hashCode;
}

final class TxChipByCategory extends TxChipFilter {
  const TxChipByCategory(this.category);
  final TransactionCategory category;

  @override
  bool operator ==(Object other) =>
      other is TxChipByCategory && other.category == category;

  @override
  int get hashCode => category.hashCode;
}

// ─── Date-grouped row ─────────────────────────────────────────────────────────

class TxGroup {
  const TxGroup({
    required this.dateLabel,
    required this.dailyTotal,
    required this.transactions,
  });

  final String dateLabel;

  /// Signed daily net: positive when income > expense for that day.
  final double dailyTotal;

  final List<Transaction> transactions;
}

// ─── Status ───────────────────────────────────────────────────────────────────

enum TransactionsStatus { loading, ready }

// ─── State ────────────────────────────────────────────────────────────────────

class TransactionsState {
  const TransactionsState({
    this.status = TransactionsStatus.loading,
    this.allTransactions = const [],
    this.monthTransactions = const [],
    this.groups = const [],
    this.searchQuery = '',
    this.activeFilter = const TxChipAll(),
    this.selectedMonth,
    this.monthIncome = 0,
    this.monthExpense = 0,
  });

  final TransactionsStatus status;
  final List<Transaction> allTransactions;

  /// All transactions in [month] BEFORE chip-filter and search. Used to
  /// compute per-chip counts in the filter row.
  final List<Transaction> monthTransactions;

  final List<TxGroup> groups;
  final String searchQuery;
  final TxChipFilter activeFilter;
  final DateTime? selectedMonth;
  final double monthIncome;
  final double monthExpense;

  DateTime get month {
    final now = DateTime.now();
    return selectedMonth ?? DateTime(now.year, now.month);
  }

  int countForFilter(TxChipFilter f) => switch (f) {
        TxChipAll() => monthTransactions.length,
        TxChipByType(:final type) =>
          monthTransactions.where((t) => t.type == type).length,
        TxChipByCategory(:final category) =>
          monthTransactions.where((t) => t.category == category).length,
      };

  /// Ordered chip list for the filter row: All → Income → categories with
  /// transactions, sorted by count descending.
  List<TxChipFilter> get visibleChips {
    final chips = <TxChipFilter>[const TxChipAll()];

    if (countForFilter(const TxChipByType(TransactionType.income)) > 0) {
      chips.add(const TxChipByType(TransactionType.income));
    }

    final catChips = TransactionCategory.values
        .where((c) => countForFilter(TxChipByCategory(c)) > 0)
        .toList()
      ..sort((a, b) => countForFilter(TxChipByCategory(b))
          .compareTo(countForFilter(TxChipByCategory(a))));

    for (final c in catChips) {
      chips.add(TxChipByCategory(c));
    }
    return chips;
  }

  TransactionsState copyWith({
    TransactionsStatus? status,
    List<Transaction>? allTransactions,
    List<Transaction>? monthTransactions,
    List<TxGroup>? groups,
    String? searchQuery,
    TxChipFilter? activeFilter,
    DateTime? selectedMonth,
    double? monthIncome,
    double? monthExpense,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      allTransactions: allTransactions ?? this.allTransactions,
      monthTransactions: monthTransactions ?? this.monthTransactions,
      groups: groups ?? this.groups,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      monthIncome: monthIncome ?? this.monthIncome,
      monthExpense: monthExpense ?? this.monthExpense,
    );
  }
}
