import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/di/app_locator.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../features/dashboard/presentation/widgets/bottom_nav.dart';
import '../../../features/transactions/data/transaction_repository.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/skeleton.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnalyticsBloc>(
      create: (_) =>
          AnalyticsBloc(repository: locator<TransactionRepository>()),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (BuildContext context, AnalyticsState state) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: <Widget>[
                _Header(),
                Expanded(
                  child: state.status == AnalyticsStatus.loading
                      ? const SingleChildScrollView(
                          child: SkeletonAnalytics(),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(
                            Spacing.s20,
                            Spacing.s16,
                            Spacing.s20,
                            Spacing.s24,
                          ),
                          children: <Widget>[
                            _PeriodTabs(
                              period: state.period,
                              onChanged: (p) => context
                                  .read<AnalyticsBloc>()
                                  .add(AnalyticsPeriodChanged(p)),
                            ),
                            const SizedBox(height: Spacing.s16),
                            _SpendChartCard(state: state),
                            const SizedBox(height: Spacing.s16),
                            _InsightCard(state: state),
                            const SizedBox(height: Spacing.s16),
                            _CategoryBarsCard(state: state),
                          ],
                        ),
                ),
                const BottomNav(),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Spacing.s20, Spacing.s20, Spacing.s20, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'MONEY STORY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Analytics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Period tabs ─────────────────────────────────────────────────────────────

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({required this.period, required this.onChanged});

  final AnalyticsPeriod period;
  final ValueChanged<AnalyticsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? theme.cardTheme.color : Colors.white,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          for (final p in AnalyticsPeriod.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(p);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 36,
                  decoration: BoxDecoration(
                    color: p == period
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      p.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: p == period
                            ? Colors.white
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Spend chart card ─────────────────────────────────────────────────────────

String _periodChartLabel(AnalyticsPeriod p) {
  final DateTime now = DateTime.now();
  return switch (p) {
    AnalyticsPeriod.week => 'This Week',
    AnalyticsPeriod.month => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][now.month - 1],
    AnalyticsPeriod.threeMonths => '3 Months',
    AnalyticsPeriod.year => '${now.year}',
    AnalyticsPeriod.all => 'All Time',
  };
}

String _prevPeriodLabel(AnalyticsPeriod p) {
  final DateTime now = DateTime.now();
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return switch (p) {
    AnalyticsPeriod.week => 'vs last week',
    AnalyticsPeriod.month => 'vs ${months[now.month == 1 ? 11 : now.month - 2]}',
    AnalyticsPeriod.threeMonths => 'vs prev 3M',
    AnalyticsPeriod.year => 'vs ${now.year - 1}',
    AnalyticsPeriod.all => '',
  };
}

class _SpendChartCard extends StatelessWidget {
  const _SpendChartCard({required this.state});
  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color accent = theme.colorScheme.primary;
    final Color bgColor = theme.cardTheme.color ??
        (isDark ? const Color(0xFF1C1C28) : Colors.white);
    final Color warning =
        isDark ? const Color(0xFFFFB547) : const Color(0xFFE89B2A);

    final List<double> values = state.chartValues;
    final bool showBudget = state.period == AnalyticsPeriod.month ||
        state.period == AnalyticsPeriod.week;
    final double pct = state.spendDeltaPct;
    final bool isDown = pct <= 0;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.all(Spacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Stat row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Total Spent · ${_periodChartLabel(state.period)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatINR(state.totalSpend),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (state.previousPeriodSpend > 0) ...<Widget>[
                      const SizedBox(height: 6),
                      Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDown
                                  ? (isDark
                                      ? const Color(0xFF00D4AA)
                                      : const Color(0xFF00B894))
                                      .withValues(alpha: 0.15)
                                  : theme.colorScheme.error
                                      .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${isDown ? '↓' : '↑'} ${pct.abs().toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDown
                                    ? (isDark
                                        ? const Color(0xFF00D4AA)
                                        : const Color(0xFF00B894))
                                    : theme.colorScheme.error,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _prevPeriodLabel(state.period),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (showBudget)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      'Budget',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatINR(state.budgetAmount),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.budgetRemaining >= 0
                          ? '${formatINR(state.budgetRemaining)} left'
                          : '${formatINR(state.budgetRemaining.abs())} over',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: state.budgetRemaining >= 0
                            ? (isDark
                                ? const Color(0xFF00D4AA)
                                : const Color(0xFF00B894))
                            : theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: Spacing.s20),

          // Chart
          if (values.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.s24),
                child: Text(
                  'No transactions in this period',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  lineTouchData: const LineTouchData(enabled: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: state.chartMaxY / 4,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.04),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 20,
                        getTitlesWidget: (double v, TitleMeta _) {
                          final int i = v.round();
                          if (i < 0 ||
                              i >= state.chartXLabels.length) {
                            return const SizedBox.shrink();
                          }
                          final String label = state.chartXLabels[i];
                          if (label.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.45),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  extraLinesData: showBudget
                      ? ExtraLinesData(
                          horizontalLines: <HorizontalLine>[
                            HorizontalLine(
                              y: state.budgetAmount,
                              color: warning.withValues(alpha: 0.7),
                              strokeWidth: 1.2,
                              dashArray: <int>[3, 4],
                              label: HorizontalLineLabel(
                                show: true,
                                alignment: Alignment.topRight,
                                padding: const EdgeInsets.only(
                                    right: 4, bottom: 2),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: warning,
                                ),
                                labelResolver: (_) => 'BUDGET',
                              ),
                            ),
                          ],
                        )
                      : null,
                  lineBarsData: <LineChartBarData>[
                    LineChartBarData(
                      spots: <FlSpot>[
                        for (int i = 0; i < values.length; i++)
                          FlSpot(i.toDouble(), values[i]),
                      ],
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: accent,
                      barWidth: 2.4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (FlSpot spot, double percent,
                            LineChartBarData bar, int index) {
                          if (index == values.length - 1) {
                            return FlDotCirclePainter(
                              radius: 5,
                              color: bgColor,
                              strokeWidth: 2.5,
                              strokeColor: accent,
                            );
                          }
                          return FlDotCirclePainter(
                            radius: 0,
                            color: Colors.transparent,
                            strokeWidth: 0,
                            strokeColor: Colors.transparent,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: <Color>[
                            accent.withValues(alpha: 0.35),
                            accent.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  minX: 0,
                  maxX: (values.length - 1).toDouble(),
                  minY: 0,
                  maxY: state.chartMaxY,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Insight card ─────────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.state});
  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color accent = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(Spacing.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? <Color>[
                  accent.withValues(alpha: 0.22),
                  accent.withValues(alpha: 0.08),
                ]
              : <Color>[
                  accent.withValues(alpha: 0.10),
                  accent.withValues(alpha: 0.02),
                ],
        ),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.30 : 0.18),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? <Color>[const Color(0xFF7B6EF6), const Color(0xFF5B4FE0)]
                        : <Color>[const Color(0xFF6358E8), const Color(0xFF4A3FC9)],
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: Spacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'FINFLOW AI · WEEKLY INSIGHT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: accent,
                      ),
                    ),
                    Text(
                      'Based on your transactions',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.s12),
          Text(
            state.insightText,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.45,
              letterSpacing: -0.2,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: Spacing.s12),
          Row(
            children: <Widget>[
              Expanded(
                child: _InsightButton(
                  label: 'See breakdown',
                  filled: true,
                  accent: accent,
                ),
              ),
              const SizedBox(width: Spacing.s8),
              Expanded(
                child: _InsightButton(
                  label: 'Share insight',
                  filled: false,
                  accent: accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightButton extends StatelessWidget {
  const _InsightButton({
    required this.label,
    required this.filled,
    required this.accent,
  });

  final String label;
  final bool filled;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: filled ? accent : Colors.transparent,
          border: Border.all(
            color: filled
                ? accent
                : accent.withValues(alpha: isDark ? 0.35 : 0.25),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: filled
                  ? Colors.white
                  : accent,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Category bars card ───────────────────────────────────────────────────────

const Map<int, Color> _categoryBarColors = <int, Color>{
  0: Color(0xFFFF5C5C),
  1: Color(0xFFFF9F47),
  2: Color(0xFFFFB547),
  3: Color(0xFF4A8FFF),
  4: Color(0xFF7B6EF6),
  5: Color(0xFF00D4AA),
  6: Color(0xFFFF7E5C),
  7: Color(0xFF8A8AFF),
};

class _CategoryBarsCard extends StatelessWidget {
  const _CategoryBarsCard({required this.state});
  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    if (state.categoryStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(Spacing.s20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'No expense data for this period',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.fromLTRB(
          Spacing.s20, Spacing.s20, Spacing.s20, Spacing.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'By category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${state.categoryStats.length} categories',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.s8),
          for (int i = 0; i < state.categoryStats.length; i++)
            _CategoryBar(
              stat: state.categoryStats[i],
              color: _categoryBarColors[i % _categoryBarColors.length] ??
                  theme.colorScheme.primary,
            ),
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.stat, required this.color});

  final CategoryStat stat;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final bool trendDown = stat.trend <= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s8),
      child: Row(
        children: <Widget>[
          CategoryIcon(category: stat.category),
          const SizedBox(width: Spacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        stat.category.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      formatINR(stat.amount),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: stat.percentage / 100,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    Text(
                      '${stat.percentage.toStringAsFixed(0)}% of spend',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    const Spacer(),
                    if (stat.trend != 0)
                      Text(
                        '${trendDown ? '↓' : '↑'} ${formatINR(stat.trend.abs())}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: trendDown
                              ? (isDark
                                  ? const Color(0xFF00D4AA)
                                  : const Color(0xFF00B894))
                              : theme.colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
