import 'package:flutter/material.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/utils/currency_formatter.dart';

/// The hero card at the top of the dashboard. Shows the total balance with
/// a privacy eye-toggle (common in Indian banking apps), the month delta,
/// and two pills for month income + expense.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    required this.totalBalance,
    required this.monthIncome,
    required this.monthExpense,
    required this.balanceHidden,
    required this.onToggleVisibility,
    super.key,
  });

  final double totalBalance;
  final double monthIncome;
  final double monthExpense;
  final bool balanceHidden;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF2A1F6E),
            Color(0xFF5B4FE0),
            Color(0xFF7B6EF6),
          ],
          stops: <double>[0.0, 0.5, 1.0],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF5B4FE0).withValues(alpha: 0.5),
            blurRadius: 50,
            offset: const Offset(0, 20),
            spreadRadius: -16,
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          // Soft shine in the top-right corner.
          Positioned(
            top: -50,
            right: -50,
            child: IgnorePointer(
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      Color(0x2EFFFFFF),
                      Color(0x00FFFFFF),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Text(
                    'TOTAL BALANCE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: Color(0xB3FFFFFF),
                    ),
                  ),
                  const SizedBox(width: Spacing.s8),
                  IconButton(
                    onPressed: onToggleVisibility,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      balanceHidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xA6FFFFFF),
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                balanceHidden ? '••••••••' : formatINR(totalBalance),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.2,
                  height: 1,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'All linked accounts',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0x99FFFFFF),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _Pill(
                      label: 'INCOME',
                      amount: monthIncome,
                      isIncome: true,
                      hidden: balanceHidden,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Pill(
                      label: 'EXPENSE',
                      amount: monthExpense,
                      isIncome: false,
                      hidden: balanceHidden,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.amount,
    required this.isIncome,
    required this.hidden,
  });

  final String label;
  final double amount;
  final bool isIncome;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final Color tint = isIncome
        ? const Color(0xFFA8FFE0)
        : const Color(0xFFFFB8B8);
    final IconData icon =
        isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final String sign = isIncome ? '+' : '−';

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x26FFFFFF)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              color: tint.withValues(alpha: 0.18),
            ),
            child: Icon(icon, color: tint, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                    color: Color(0x99FFFFFF),
                  ),
                ),
                Text(
                  hidden ? '••••••' : '$sign${formatINR(amount)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: Colors.white,
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
