import '../../../shared/models/transaction.dart';
import '../../../shared/models/transaction_category.dart';

// ─── Period ───────────────────────────────────────────────────────────────────

enum AnalyticsPeriod {
  week,
  month,
  threeMonths,
  year,
  all;

  String get label => switch (this) {
        AnalyticsPeriod.week => 'Week',
        AnalyticsPeriod.month => 'Month',
        AnalyticsPeriod.threeMonths => '3M',
        AnalyticsPeriod.year => 'Year',
        AnalyticsPeriod.all => 'All',
      };
}

// ─── Category stat ────────────────────────────────────────────────────────────

class CategoryStat {
  const CategoryStat({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.trend,
  });

  final TransactionCategory category;
  final double amount;

  /// 0–100: share of total expenses in the period.
  final double percentage;

  /// Signed delta vs previous period. Negative = spent less (good).
  final double trend;
}

// ─── Status ───────────────────────────────────────────────────────────────────

enum AnalyticsStatus { loading, ready }

// ─── State ────────────────────────────────────────────────────────────────────

class AnalyticsState {
  const AnalyticsState({
    this.status = AnalyticsStatus.loading,
    this.allTransactions = const [],
    this.period = AnalyticsPeriod.month,
    this.chartValues = const [],
    this.chartXLabels = const [],
    this.chartMaxY = 50000,
    this.budgetAmount = 40000,
    this.totalSpend = 0,
    this.totalIncome = 0,
    this.previousPeriodSpend = 0,
    this.categoryStats = const [],
    this.insightText = '',
  });

  final AnalyticsStatus status;
  final List<Transaction> allTransactions;
  final AnalyticsPeriod period;

  /// Y-values for the line chart; x-index is position in list.
  final List<double> chartValues;

  /// One label per chart value. Empty string = hidden tick.
  final List<String> chartXLabels;

  final double chartMaxY;
  final double budgetAmount;
  final double totalSpend;
  final double totalIncome;
  final double previousPeriodSpend;
  final List<CategoryStat> categoryStats;
  final String insightText;

  double get spendDeltaPct {
    if (previousPeriodSpend == 0) return 0;
    return (totalSpend - previousPeriodSpend) / previousPeriodSpend * 100;
  }

  double get budgetRemaining => budgetAmount - totalSpend;

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    List<Transaction>? allTransactions,
    AnalyticsPeriod? period,
    List<double>? chartValues,
    List<String>? chartXLabels,
    double? chartMaxY,
    double? budgetAmount,
    double? totalSpend,
    double? totalIncome,
    double? previousPeriodSpend,
    List<CategoryStat>? categoryStats,
    String? insightText,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      allTransactions: allTransactions ?? this.allTransactions,
      period: period ?? this.period,
      chartValues: chartValues ?? this.chartValues,
      chartXLabels: chartXLabels ?? this.chartXLabels,
      chartMaxY: chartMaxY ?? this.chartMaxY,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      totalSpend: totalSpend ?? this.totalSpend,
      totalIncome: totalIncome ?? this.totalIncome,
      previousPeriodSpend: previousPeriodSpend ?? this.previousPeriodSpend,
      categoryStats: categoryStats ?? this.categoryStats,
      insightText: insightText ?? this.insightText,
    );
  }
}
