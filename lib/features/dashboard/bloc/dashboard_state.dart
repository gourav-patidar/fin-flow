import 'package:equatable/equatable.dart';

import '../../../shared/models/transaction.dart';
import '../../../shared/models/transaction_category.dart';

enum DashboardStatus { loading, ready }

/// Derived view-model the Dashboard screen consumes. All numeric fields are
/// computed by [DashboardCalculations] off the latest transaction snapshot.
class DashboardState extends Equatable {
  const DashboardState({
    required this.status,
    required this.totalBalance,
    required this.monthIncome,
    required this.monthExpense,
    required this.categoryBreakdown,
    required this.recentTransactions,
    required this.balanceHidden,
  });

  const DashboardState.initial()
      : status = DashboardStatus.loading,
        totalBalance = 0,
        monthIncome = 0,
        monthExpense = 0,
        categoryBreakdown = const <TransactionCategory, double>{},
        recentTransactions = const <Transaction>[],
        balanceHidden = false;

  final DashboardStatus status;
  final double totalBalance;
  final double monthIncome;
  final double monthExpense;
  final Map<TransactionCategory, double> categoryBreakdown;
  final List<Transaction> recentTransactions;
  final bool balanceHidden;

  DashboardState copyWith({
    DashboardStatus? status,
    double? totalBalance,
    double? monthIncome,
    double? monthExpense,
    Map<TransactionCategory, double>? categoryBreakdown,
    List<Transaction>? recentTransactions,
    bool? balanceHidden,
  }) {
    return DashboardState(
      status: status ?? this.status,
      totalBalance: totalBalance ?? this.totalBalance,
      monthIncome: monthIncome ?? this.monthIncome,
      monthExpense: monthExpense ?? this.monthExpense,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      balanceHidden: balanceHidden ?? this.balanceHidden,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        totalBalance,
        monthIncome,
        monthExpense,
        categoryBreakdown,
        recentTransactions,
        balanceHidden,
      ];
}
