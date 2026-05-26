import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/di/app_locator.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../features/dashboard/presentation/widgets/add_transaction_sheet.dart';
import '../../../features/dashboard/presentation/widgets/bottom_nav.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../../shared/widgets/transaction_tile.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
import '../bloc/transactions_state.dart';
import '../data/transaction_repository.dart';

// ─── Month helpers ────────────────────────────────────────────────────────────

String _monthFull(DateTime m) => '${const [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ][m.month - 1]} ${m.year}';

String _monthAbbr(DateTime m) => const [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][m.month - 1];

// ─── Screen ───────────────────────────────────────────────────────────────────

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionsBloc>(
      create: (_) =>
          TransactionsBloc(repository: locator<TransactionRepository>()),
      child: const _TransactionsView(),
    );
  }
}

// ─── View (stateful for search controller) ───────────────────────────────────

class _TransactionsView extends StatefulWidget {
  const _TransactionsView();

  @override
  State<_TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<_TransactionsView> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _pickMonth(BuildContext context, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      helpText: 'SELECT MONTH',
    );
    if (picked == null || !context.mounted) return;
    context.read<TransactionsBloc>().add(
          TransactionsMonthChanged(DateTime(picked.year, picked.month)),
        );
  }

  Future<void> _openAddSheet(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    await AddTransactionSheet.show(context, userId: authState.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (BuildContext context, TransactionsState state) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _Header(
                  state: state,
                  onMonthTap: () => _pickMonth(context, state.month),
                ),
                const SizedBox(height: Spacing.s12),
                _SummaryStrip(
                  income: state.monthIncome,
                  expense: state.monthExpense,
                ),
                const SizedBox(height: Spacing.s12),
                _SearchRow(
                  controller: _search,
                  onChanged: (q) => context
                      .read<TransactionsBloc>()
                      .add(TransactionsSearchChanged(q)),
                  onExport: () => context
                      .read<TransactionsBloc>()
                      .add(const TransactionsCsvExportRequested()),
                ),
                const SizedBox(height: Spacing.s12),
                _FilterChipRow(
                  state: state,
                  onChanged: (f) => context
                      .read<TransactionsBloc>()
                      .add(TransactionsFilterChanged(f)),
                ),
                const SizedBox(height: Spacing.s8),
                Expanded(
                  child: switch (state.status) {
                    TransactionsStatus.loading =>
                      const SkeletonTransactionList(),
                    TransactionsStatus.ready when state.groups.isEmpty =>
                      _EmptyState(onAdd: () => _openAddSheet(context)),
                    TransactionsStatus.ready => _GroupedList(
                        groups: state.groups,
                        onDelete: (id) => context
                            .read<TransactionsBloc>()
                            .add(TransactionDeleteRequested(id)),
                      ),
                  },
                ),
                const BottomNav(),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openAddSheet(context),
            tooltip: 'Add transaction',
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.state, required this.onMonthTap});

  final TransactionsState state;
  final VoidCallback onMonthTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime m = state.month;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.s20, Spacing.s20, Spacing.s20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _monthFull(m).toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Transactions',
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
          GestureDetector(
            onTap: onMonthTap,
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.s12),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _monthAbbr(m),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Summary strip ────────────────────────────────────────────────────────────

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.income, required this.expense});

  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.s20),
      child: Row(
        children: <Widget>[
          Expanded(child: _MiniCard(label: 'INCOME', amount: income, isIncome: true)),
          const SizedBox(width: Spacing.s12),
          Expanded(child: _MiniCard(label: 'EXPENSE', amount: expense, isIncome: false)),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.label,
    required this.amount,
    required this.isIncome,
  });

  final String label;
  final double amount;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color color = isIncome
        ? (isDark ? const Color(0xFF00D4AA) : const Color(0xFF00B894))
        : (isDark ? const Color(0xFFFF5C5C) : const Color(0xFFE53E3E));
    final Color bg = isIncome
        ? color.withValues(alpha: isDark ? 0.08 : 0.06)
        : color.withValues(alpha: isDark ? 0.08 : 0.06);
    final Color border = color.withValues(alpha: isDark ? 0.18 : 0.15);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  isIncome
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatINR(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search row ───────────────────────────────────────────────────────────────

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.onChanged,
    required this.onExport,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.s20),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? theme.cardTheme.color : Colors.white,
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search transactions…',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: Spacing.s8),
          GestureDetector(
            onTap: onExport,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? theme.cardTheme.color : Colors.white,
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.ios_share_rounded,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter chips ─────────────────────────────────────────────────────────────

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({required this.state, required this.onChanged});

  final TransactionsState state;
  final ValueChanged<TxChipFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final List<TxChipFilter> chips = state.visibleChips;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.s20),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: Spacing.s8),
        itemBuilder: (BuildContext context, int i) {
          final TxChipFilter chip = chips[i];
          final bool active = chip == state.activeFilter;
          final int count = state.countForFilter(chip);
          return _Chip(
            label: chip.label,
            count: count,
            active: active,
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(chip);
            },
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color accent = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? accent : (isDark ? theme.cardTheme.color : Colors.white),
          border: Border.all(color: active ? accent : theme.dividerColor),
          borderRadius: BorderRadius.circular(999),
          boxShadow: active
              ? <BoxShadow>[
                  BoxShadow(
                    color: accent.withValues(alpha: isDark ? 0.4 : 0.3),
                    blurRadius: isDark ? 20 : 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
                color: active
                    ? Colors.white
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (count > 0) ...<Widget>[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withValues(alpha: 0.22)
                      : accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : accent,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Grouped list ─────────────────────────────────────────────────────────────

class _GroupedList extends StatelessWidget {
  const _GroupedList({required this.groups, required this.onDelete});

  final List<TxGroup> groups;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        Spacing.s20,
        Spacing.s8,
        Spacing.s20,
        Spacing.s24,
      ),
      itemCount: groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: Spacing.s16),
      itemBuilder: (BuildContext context, int i) =>
          _TxGroupSection(group: groups[i], onDelete: onDelete),
    );
  }
}

class _TxGroupSection extends StatelessWidget {
  const _TxGroupSection({required this.group, required this.onDelete});

  final TxGroup group;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final bool netPositive = group.dailyTotal >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Date header row
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 8),
          child: Row(
            children: <Widget>[
              Text(
                group.dateLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${netPositive ? '+' : ''}${formatINR(group.dailyTotal)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
        // Card with rows
        Container(
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
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: <Widget>[
              for (int i = 0; i < group.transactions.length; i++) ...<Widget>[
                Dismissible(
                  key: ValueKey<String>(group.transactions[i].id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    HapticFeedback.heavyImpact();
                    onDelete(group.transactions[i].id);
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: Spacing.s20),
                    color: isDark
                        ? const Color(0xFF2A0A0A)
                        : const Color(0xFFFFF0F0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.delete_outline_rounded,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  child: TransactionTile(
                    transaction: group.transactions[i],
                  ),
                ),
                if (i < group.transactions.length - 1)
                  Divider(
                    height: 1,
                    color: theme.dividerColor,
                    indent: 68,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: Spacing.s16),
          Text(
            'No transactions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different filter or add one.',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: Spacing.s20),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add transaction'),
          ),
        ],
      ),
    );
  }
}
