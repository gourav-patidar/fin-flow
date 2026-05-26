import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import 'category_icon.dart';

/// One row in any transaction list — Dashboard recent activity, the full
/// Transactions screen, the Payments recent list. The trailing amount is
/// signed by [TransactionType] and colored income/expense from the theme.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.transaction,
    this.onTap,
    super.key,
  });

  final Transaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isIncome = transaction.type == TransactionType.income;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color incomeColor =
        isDark ? AppColorsDark.income : AppColorsLight.income;
    final Color amountColor =
        isIncome ? incomeColor : theme.colorScheme.onSurface;

    final String prefix = isIncome ? '+' : '-';
    final String amountText = '$prefix${formatINR(transaction.amount)}';
    final String dateText = formatRelativeDate(transaction.date);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            CategoryIcon(category: transaction.category),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    transaction.merchant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${transaction.category.label} · $dateText',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amountText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
