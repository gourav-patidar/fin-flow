import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/di/app_locator.dart';
import '../../../core/services/seed_service.dart';
import '../../../shared/models/transaction.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/transaction_tile.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../transactions/data/transaction_repository.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../../shared/widgets/skeleton.dart';
import 'widgets/add_transaction_sheet.dart';
import 'widgets/balance_card.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/category_donut.dart';
import 'widgets/quick_actions.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>(
      create: (_) => DashboardBloc(repository: locator<TransactionRepository>()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Triggering a write would re-emit the stream; for now
                  // refreshing the local-only repo is a no-op signal.
                  await Future<void>.delayed(
                    const Duration(milliseconds: 300),
                  );
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.s20,
                    Spacing.s20,
                    Spacing.s20,
                    Spacing.s24,
                  ),
                  children: <Widget>[
                    _Greeting(theme: theme),
                    const SizedBox(height: Spacing.s20),
                    BlocBuilder<DashboardBloc, DashboardState>(
                      builder: (BuildContext context, DashboardState state) {
                        return BalanceCard(
                          totalBalance: state.totalBalance,
                          monthIncome: state.monthIncome,
                          monthExpense: state.monthExpense,
                          balanceHidden: state.balanceHidden,
                          onToggleVisibility: () => context
                              .read<DashboardBloc>()
                              .add(const DashboardBalanceVisibilityToggled()),
                        );
                      },
                    ),
                    const SizedBox(height: Spacing.s20),
                    QuickActions(
                      onAdd: () => _openAddSheet(context),
                      onTransfer: () => _comingSoon(context, 'Transfer'),
                      onPay: () => _comingSoon(context, 'Pay'),
                      onScan: () => _comingSoon(context, 'Scan'),
                    ),
                    const SizedBox(height: Spacing.s20),
                    BlocBuilder<DashboardBloc, DashboardState>(
                      builder: (BuildContext context, DashboardState state) {
                        return CategoryDonut(breakdown: state.categoryBreakdown);
                      },
                    ),
                    const SizedBox(height: Spacing.s20),
                    SectionHeader(
                      title: 'Recent activity',
                      actionLabel: 'See all',
                      onActionTap: () => context.go(Routes.transactions),
                    ),
                    const SizedBox(height: Spacing.s8),
                    BlocBuilder<DashboardBloc, DashboardState>(
                      builder: (BuildContext context, DashboardState state) {
                        if (state.status == DashboardStatus.loading) {
                          return const _ListLoading();
                        }
                        if (state.recentTransactions.isEmpty) {
                          return _EmptyRecent(
                            onAdd: () => _openAddSheet(context),
                          );
                        }
                        return _RecentList(
                          transactions: state.recentTransactions,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const BottomNav(),
          ],
        ),
      ),
    );
  }

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — coming soon')),
    );
  }

  Future<void> _openAddSheet(BuildContext context) async {
    final AuthState s = context.read<AuthBloc>().state;
    if (s is! AuthAuthenticated) return;
    await AddTransactionSheet.show(context, userId: s.user.id);
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, AuthState state) {
        final String greeting = _timeOfDayGreeting();
        final String name = state is AuthAuthenticated
            ? state.user.displayName.split(' ').first
            : 'there';
        return Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    greeting,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (kDebugMode)
              IconButton(
                tooltip: 'Seed 30 sample transactions',
                onPressed: () async {
                  if (state is! AuthAuthenticated) return;
                  await locator<SeedService>().seed(userId: state.user.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Seeded 30 sample transactions'),
                    ),
                  );
                },
                icon: const Icon(Icons.bolt_rounded),
              ),
            IconButton(
              tooltip: 'Sign out',
              onPressed: () => context
                  .read<AuthBloc>()
                  .add(const AuthSignOutRequested()),
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        );
      },
    );
  }

  String _timeOfDayGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _RecentList extends StatelessWidget {
  const _RecentList({required this.transactions});
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.s16, vertical: 4),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < transactions.length; i++) ...<Widget>[
            TransactionTile(transaction: transactions[i]),
            if (i != transactions.length - 1)
              Divider(height: 1, color: theme.dividerColor),
          ],
        ],
      ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.receipt_long_outlined,
            size: 36,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: Spacing.s12),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Add your first one to start tracking.',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: Spacing.s12),
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

class _ListLoading extends StatelessWidget {
  const _ListLoading();

  @override
  Widget build(BuildContext context) {
    return const SkeletonTransactionList(count: 6);
  }
}
