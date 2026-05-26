import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../shared/models/transaction.dart';
import '../../../shared/models/transaction_category.dart';
import '../../../shared/models/transaction_type.dart';
import '../../../features/transactions/data/transaction_repository.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc({required TransactionRepository repository})
      : super(const AnalyticsState()) {
    on<AnalyticsDataChanged>(_onDataChanged);
    on<AnalyticsPeriodChanged>(_onPeriodChanged);

    _sub = repository
        .watchTransactions()
        .listen((txns) => add(AnalyticsDataChanged(txns)));
  }

  late final StreamSubscription<List<Transaction>> _sub;

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }

  void _onDataChanged(
    AnalyticsDataChanged event,
    Emitter<AnalyticsState> emit,
  ) {
    emit(_recompute(state.copyWith(
      status: AnalyticsStatus.ready,
      allTransactions: event.transactions,
    )));
  }

  void _onPeriodChanged(
    AnalyticsPeriodChanged event,
    Emitter<AnalyticsState> emit,
  ) =>
      emit(_recompute(state.copyWith(period: event.period)));

  // ─── Computation ─────────────────────────────────────────────────────────

  AnalyticsState _recompute(AnalyticsState s) {
    final now = DateTime.now();
    final range = _currentRange(s.period, now);
    final prev = _prevRange(s.period, range.from, now);

    bool inRange(Transaction t, ({DateTime from, DateTime to}) r) =>
        !t.date.isBefore(r.from) && !t.date.isAfter(r.to);

    final currentTxns = s.allTransactions.where((t) => inRange(t, range)).toList();
    final prevTxns = s.allTransactions.where((t) => inRange(t, prev)).toList();

    final totalSpend = _sumExpenses(currentTxns);
    final totalIncome = _sumIncome(currentTxns);
    final prevSpend = _sumExpenses(prevTxns);

    final catStats = _computeCategories(currentTxns, prevTxns, totalSpend);
    final chartData = _computeChart(currentTxns, s.period, range, now);
    final insight = _insight(catStats, totalSpend, prevSpend, s.period);

    return s.copyWith(
      totalSpend: totalSpend,
      totalIncome: totalIncome,
      previousPeriodSpend: prevSpend,
      categoryStats: catStats,
      chartValues: chartData.$1,
      chartXLabels: chartData.$2,
      chartMaxY: chartData.$3,
      insightText: insight,
    );
  }

  // ─── Date ranges ─────────────────────────────────────────────────────────

  ({DateTime from, DateTime to}) _currentRange(AnalyticsPeriod p, DateTime now) {
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return switch (p) {
      AnalyticsPeriod.week => (
          from: DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 6)),
          to: todayEnd,
        ),
      AnalyticsPeriod.month => (
          from: DateTime(now.year, now.month, 1),
          to: todayEnd,
        ),
      AnalyticsPeriod.threeMonths => (
          from: _monthsAgo(now, 2),
          to: todayEnd,
        ),
      AnalyticsPeriod.year => (
          from: DateTime(now.year, 1, 1),
          to: todayEnd,
        ),
      AnalyticsPeriod.all => (
          from: DateTime(2020, 1, 1),
          to: todayEnd,
        ),
    };
  }

  ({DateTime from, DateTime to}) _prevRange(
    AnalyticsPeriod p,
    DateTime currentFrom,
    DateTime now,
  ) =>
      switch (p) {
        AnalyticsPeriod.week => (
            from: currentFrom.subtract(const Duration(days: 7)),
            to: currentFrom.subtract(const Duration(seconds: 1)),
          ),
        AnalyticsPeriod.month => (
            from: _monthsAgo(now, 1),
            to: DateTime(now.year, now.month, 0, 23, 59, 59),
          ),
        AnalyticsPeriod.threeMonths => (
            from: _monthsAgo(now, 5),
            to: _monthsAgo(now, 2).subtract(const Duration(seconds: 1)),
          ),
        AnalyticsPeriod.year => (
            from: DateTime(now.year - 1, 1, 1),
            to: DateTime(now.year - 1, 12, 31, 23, 59, 59),
          ),
        AnalyticsPeriod.all => (
            from: DateTime(2020, 1, 1),
            to: DateTime(2020, 1, 2),
          ),
      };

  static DateTime _monthsAgo(DateTime now, int n) {
    int year = now.year;
    int month = now.month - n;
    while (month <= 0) {
      month += 12;
      year--;
    }
    return DateTime(year, month, 1);
  }

  // ─── Chart data ───────────────────────────────────────────────────────────

  /// Returns (values, xLabels, maxY).
  (List<double>, List<String>, double) _computeChart(
    List<Transaction> txns,
    AnalyticsPeriod period,
    ({DateTime from, DateTime to}) range,
    DateTime now,
  ) {
    final expenses = txns.where((t) => t.type == TransactionType.expense).toList();

    if (period == AnalyticsPeriod.week || period == AnalyticsPeriod.month) {
      return _dailyCumulative(expenses, range.from, now, period);
    } else {
      return _monthlyTotals(expenses, range.from, now);
    }
  }

  (List<double>, List<String>, double) _dailyCumulative(
    List<Transaction> expenses,
    DateTime from,
    DateTime now,
    AnalyticsPeriod period,
  ) {
    final fromDay = DateTime(from.year, from.month, from.day);
    final days = DateTime(now.year, now.month, now.day).difference(fromDay).inDays + 1;
    if (days <= 0) return (const [], const [], 50000);

    final values = <double>[];
    double running = 0;
    for (int i = 0; i < days; i++) {
      final d = fromDay.add(Duration(days: i));
      final dayAmt = expenses
          .where((t) =>
              t.date.year == d.year &&
              t.date.month == d.month &&
              t.date.day == d.day)
          .fold(0.0, (s, t) => s + t.amount);
      running += dayAmt;
      values.add(running);
    }

    final labels = List<String>.filled(days, '');
    if (period == AnalyticsPeriod.week) {
      const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (int i = 0; i < days; i++) {
        labels[i] = wd[fromDay.add(Duration(days: i)).weekday - 1];
      }
    } else {
      // Month: tick at day 1, ~7, ~14, today
      labels[0] = '1';
      if (days > 7) labels[6] = '7';
      if (days > 14) labels[13] = '14';
      if (days > 1) labels[days - 1] = '${fromDay.day + days - 1}';
    }

    final maxRaw = values.isEmpty ? 50000.0 : values.last;
    final maxY = (maxRaw * 1.35).clamp(10000.0, double.infinity);
    return (values, labels, maxY);
  }

  (List<double>, List<String>, double) _monthlyTotals(
    List<Transaction> expenses,
    DateTime from,
    DateTime now,
  ) {
    final months = <DateTime>[];
    var m = DateTime(from.year, from.month, 1);
    final limit = DateTime(now.year, now.month, 1);
    while (!m.isAfter(limit)) {
      months.add(m);
      int y = m.year, mo = m.month + 1;
      if (mo > 12) { mo = 1; y++; }
      m = DateTime(y, mo, 1);
    }

    if (months.isEmpty) return (const [], const [], 50000);

    final values = months.map((mo) {
      return expenses
          .where((t) => t.date.year == mo.year && t.date.month == mo.month)
          .fold(0.0, (s, t) => s + t.amount);
    }).toList();

    const abbr = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final labels = months.map((mo) => abbr[mo.month - 1]).toList();

    final peak = values.isEmpty ? 50000.0 : values.reduce((a, b) => a > b ? a : b);
    final maxY = (peak * 1.35).clamp(10000.0, double.infinity);
    return (values, labels, maxY);
  }

  // ─── Category stats ───────────────────────────────────────────────────────

  List<CategoryStat> _computeCategories(
    List<Transaction> current,
    List<Transaction> prev,
    double totalSpend,
  ) {
    final Map<TransactionCategory, double> cur = {};
    final Map<TransactionCategory, double> pre = {};

    for (final t in current.where((t) => t.type == TransactionType.expense)) {
      cur[t.category] = (cur[t.category] ?? 0) + t.amount;
    }
    for (final t in prev.where((t) => t.type == TransactionType.expense)) {
      pre[t.category] = (pre[t.category] ?? 0) + t.amount;
    }

    final stats = [
      for (final e in cur.entries)
        CategoryStat(
          category: e.key,
          amount: e.value,
          percentage: totalSpend > 0 ? e.value / totalSpend * 100 : 0,
          trend: e.value - (pre[e.key] ?? 0),
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    return stats;
  }

  // ─── Insight text ─────────────────────────────────────────────────────────

  static String _insight(
    List<CategoryStat> stats,
    double totalSpend,
    double prevSpend,
    AnalyticsPeriod period,
  ) {
    if (stats.isEmpty) {
      return 'Add transactions to unlock spending insights.';
    }

    final periodStr = switch (period) {
      AnalyticsPeriod.week => 'this week',
      AnalyticsPeriod.month => 'this month',
      AnalyticsPeriod.threeMonths => 'over 3 months',
      AnalyticsPeriod.year => 'this year',
      AnalyticsPeriod.all => 'overall',
    };

    final savings = stats
        .where((s) => s.trend < -100)
        .toList()
      ..sort((a, b) => a.trend.compareTo(b.trend));

    if (savings.isNotEmpty && prevSpend > 0) {
      final s = savings.first;
      final saved = s.trend.abs();
      final projected = saved * 3;
      return 'You spent ${formatINR(saved)} less on ${s.category.label} $periodStr. '
          'Keep it up to save ${formatINR(projected)} over 3 months.';
    }

    if (prevSpend > 0 && totalSpend < prevSpend) {
      final pct = ((prevSpend - totalSpend) / prevSpend * 100).toStringAsFixed(1);
      return 'Great news — total spending is down $pct% vs last period. '
          'You\'re on track to save more this month.';
    }

    if (stats.isNotEmpty) {
      final top = stats.first;
      final pct = top.percentage.toStringAsFixed(0);
      return '${top.category.label} is your biggest expense at $pct% of total spend $periodStr. '
          'Setting a category budget could help you save.';
    }

    return 'You\'ve tracked ${formatINR(totalSpend)} in expenses $periodStr. '
        'Keep adding transactions for personalised insights.';
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  static double _sumExpenses(List<Transaction> txns) => txns
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (s, t) => s + t.amount);

  static double _sumIncome(List<Transaction> txns) => txns
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (s, t) => s + t.amount);
}
