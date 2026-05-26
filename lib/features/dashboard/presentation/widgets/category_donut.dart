import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/transaction_category.dart';
import '../../../../shared/widgets/glass_card.dart';

/// Donut chart of this-month expenses by category. Tapping a slice expands
/// it and surfaces that category's label + amount in the centre. Empty
/// breakdown renders a friendly placeholder.
class CategoryDonut extends StatefulWidget {
  const CategoryDonut({required this.breakdown, super.key});

  final Map<TransactionCategory, double> breakdown;

  @override
  State<CategoryDonut> createState() => _CategoryDonutState();
}

class _CategoryDonutState extends State<CategoryDonut> {
  int? _touched;

  static const Map<TransactionCategory, Color> _palette =
      <TransactionCategory, Color>{
    TransactionCategory.foodAndDining: Color(0xFFFF5C5C),
    TransactionCategory.groceries: Color(0xFF00D4AA),
    TransactionCategory.transport: Color(0xFF4FACFE),
    TransactionCategory.billsAndUtilities: Color(0xFFFFB547),
    TransactionCategory.shopping: Color(0xFFEC4899),
    TransactionCategory.entertainment: Color(0xFF7B6EF6),
    TransactionCategory.health: Color(0xFFEF4444),
    TransactionCategory.investments: Color(0xFF14B8A6),
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<MapEntry<TransactionCategory, double>> entries =
        widget.breakdown.entries.toList()
          ..sort((MapEntry<TransactionCategory, double> a,
                  MapEntry<TransactionCategory, double> b) =>
              b.value.compareTo(a.value));
    final double total =
        entries.fold<double>(0, (double acc, MapEntry<TransactionCategory, double> e) => acc + e.value);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Spend by category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'This month',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.s16),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.s24),
              child: Center(
                child: Text(
                  'No spend yet this month',
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 50,
                            startDegreeOffset: -90,
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent _, PieTouchResponse? r) {
                                setState(() {
                                  _touched =
                                      r?.touchedSection?.touchedSectionIndex;
                                });
                              },
                            ),
                            sections: List<PieChartSectionData>.generate(
                              entries.length,
                              (int i) {
                                final MapEntry<TransactionCategory, double> e =
                                    entries[i];
                                final bool active = i == _touched;
                                return PieChartSectionData(
                                  color: _palette[e.key]!,
                                  value: e.value,
                                  radius: active ? 34 : 28,
                                  showTitle: false,
                                );
                              },
                            ),
                          ),
                        ),
                        _CenterLabel(
                          entries: entries,
                          total: total,
                          touched: _touched,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        for (int i = 0;
                            i < entries.length.clamp(0, 4);
                            i++)
                          _Legend(
                            color: _palette[entries[i].key]!,
                            label: entries[i].key.label,
                            value: entries[i].value,
                            total: total,
                          ),
                      ],
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

class _CenterLabel extends StatelessWidget {
  const _CenterLabel({
    required this.entries,
    required this.total,
    required this.touched,
  });

  final List<MapEntry<TransactionCategory, double>> entries;
  final double total;
  final int? touched;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    String label = 'SPENT';
    double amount = total;
    if (touched != null && touched! >= 0 && touched! < entries.length) {
      final MapEntry<TransactionCategory, double> e = entries[touched!];
      label = e.key.label.toUpperCase();
      amount = e.value;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formatINR(amount),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    required this.value,
    required this.total,
  });

  final Color color;
  final String label;
  final double value;
  final double total;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int pct = total > 0 ? ((value / total) * 100).round() : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            '$pct%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
