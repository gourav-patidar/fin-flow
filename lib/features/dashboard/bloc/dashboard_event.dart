import 'package:equatable/equatable.dart';

import '../../../shared/models/transaction.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => <Object?>[];
}

/// Toggles the eye icon on [BalanceCard] — hides/shows the amount for the
/// "over-the-shoulder" privacy pattern common in Indian banking apps.
class DashboardBalanceVisibilityToggled extends DashboardEvent {
  const DashboardBalanceVisibilityToggled();
}

/// Internal — repository stream emitted a new list. Not for UI to dispatch.
class DashboardTransactionsChanged extends DashboardEvent {
  const DashboardTransactionsChanged(this.transactions);
  final List<Transaction> transactions;

  @override
  List<Object?> get props => <Object?>[transactions];
}
