import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../shared/models/transaction.dart';
import '../../../shared/models/transaction_type.dart';
import '../data/transaction_repository.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc({required TransactionRepository repository})
      : _repository = repository,
        super(const TransactionsState()) {
    on<TransactionsDataChanged>(_onDataChanged);
    on<TransactionsSearchChanged>(_onSearchChanged);
    on<TransactionsFilterChanged>(_onFilterChanged);
    on<TransactionsMonthChanged>(_onMonthChanged);
    on<TransactionDeleteRequested>(_onDeleteRequested);
    on<TransactionsCsvExportRequested>(_onCsvExport);

    _sub = repository
        .watchTransactions()
        .listen((txns) => add(TransactionsDataChanged(txns)));
  }

  final TransactionRepository _repository;
  late final StreamSubscription<List<Transaction>> _sub;

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }

  // ─── Event handlers ──────────────────────────────────────────────────────

  void _onDataChanged(
    TransactionsDataChanged event,
    Emitter<TransactionsState> emit,
  ) {
    emit(_recompute(state.copyWith(
      status: TransactionsStatus.ready,
      allTransactions: event.transactions,
    )));
  }

  void _onSearchChanged(
    TransactionsSearchChanged event,
    Emitter<TransactionsState> emit,
  ) =>
      emit(_recompute(state.copyWith(searchQuery: event.query)));

  void _onFilterChanged(
    TransactionsFilterChanged event,
    Emitter<TransactionsState> emit,
  ) =>
      emit(_recompute(state.copyWith(activeFilter: event.filter)));

  void _onMonthChanged(
    TransactionsMonthChanged event,
    Emitter<TransactionsState> emit,
  ) =>
      emit(_recompute(state.copyWith(selectedMonth: event.month)));

  Future<void> _onDeleteRequested(
    TransactionDeleteRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    await _repository.deleteTransaction(event.id);
  }

  Future<void> _onCsvExport(
    TransactionsCsvExportRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    final txns = state.groups.expand((g) => g.transactions).toList();
    if (txns.isEmpty) return;

    final rows = <List<dynamic>>[
      ['Date', 'Merchant', 'Category', 'Type', 'Amount (INR)', 'Payment Method', 'Note'],
      for (final t in txns)
        [
          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}',
          t.merchant,
          t.category.label,
          t.type.name,
          t.amount.toStringAsFixed(2),
          t.paymentMethod.label,
          t.note ?? '',
        ],
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final m = state.month;
    final file = File(
      '${dir.path}/finflow_${m.year}_${m.month.toString().padLeft(2, '0')}.csv',
    );
    await file.writeAsString(csv);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'FinFlow Transactions Export',
    );
  }

  // ─── Derived state ───────────────────────────────────────────────────────

  TransactionsState _recompute(TransactionsState s) {
    final month = s.month;

    final monthTxns = s.allTransactions
        .where((t) => t.date.year == month.year && t.date.month == month.month)
        .toList();

    final monthIncome = monthTxns
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final monthExpense = monthTxns
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    var visible = switch (s.activeFilter) {
      TxChipAll() => monthTxns,
      TxChipByType(:final type) =>
        monthTxns.where((t) => t.type == type).toList(),
      TxChipByCategory(:final category) =>
        monthTxns.where((t) => t.category == category).toList(),
    };

    final q = s.searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      visible = visible.where((t) {
        return t.merchant.toLowerCase().contains(q) ||
            (t.note?.toLowerCase().contains(q) ?? false) ||
            t.category.label.toLowerCase().contains(q);
      }).toList();
    }

    visible.sort((a, b) => b.date.compareTo(a.date));

    return s.copyWith(
      monthTransactions: monthTxns,
      groups: _buildGroups(visible),
      monthIncome: monthIncome,
      monthExpense: monthExpense,
    );
  }

  List<TxGroup> _buildGroups(List<Transaction> sorted) {
    if (sorted.isEmpty) return [];
    final Map<String, List<Transaction>> byDay = {};
    for (final t in sorted) {
      final key = '${t.date.year}-${t.date.month}-${t.date.day}';
      (byDay[key] ??= []).add(t);
    }
    return [
      for (final entry in byDay.entries)
        TxGroup(
          dateLabel: _dayLabel(entry.value.first.date),
          dailyTotal: entry.value.fold(
            0.0,
            (sum, t) => sum + (t.type.isIncome ? t.amount : -t.amount),
          ),
          transactions: entry.value,
        ),
    ];
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;
    final mon = _monthAbbr(date.month);
    if (diff == 0) return 'Today, ${date.day} $mon';
    if (diff == 1) return 'Yesterday, ${date.day} $mon';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${date.day} $mon';
  }

  static String _monthAbbr(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][m - 1];
}
