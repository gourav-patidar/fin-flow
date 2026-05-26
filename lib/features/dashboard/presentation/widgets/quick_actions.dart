import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// The 4-tile row under the BalanceCard. Only "Add" has a real handler;
/// the others wear a "Coming soon" SnackBar until later phases implement them.
class QuickActions extends StatelessWidget {
  const QuickActions({
    required this.onAdd,
    required this.onTransfer,
    required this.onPay,
    required this.onScan,
    super.key,
  });

  final VoidCallback onAdd;
  final VoidCallback onTransfer;
  final VoidCallback onPay;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color accent =
        isDark ? AppColorsDark.accent : AppColorsLight.accent;
    final Color income =
        isDark ? AppColorsDark.income : AppColorsLight.income;
    final Color warning =
        isDark ? AppColorsDark.warning : AppColorsLight.warning;

    return Row(
      children: <Widget>[
        Expanded(
          child: _Tile(
            label: 'Add',
            icon: Icons.add_rounded,
            iconColor: accent,
            onTap: onAdd,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Tile(
            label: 'Transfer',
            icon: Icons.swap_horiz_rounded,
            iconColor: income,
            onTap: onTransfer,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Tile(
            label: 'Pay',
            icon: Icons.payments_outlined,
            iconColor: warning,
            onTap: onPay,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Tile(
            label: 'Scan',
            icon: Icons.qr_code_scanner_rounded,
            iconColor: accent,
            onTap: onScan,
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Material(
          color: theme.cardTheme.color ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Icon(icon, color: iconColor),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
