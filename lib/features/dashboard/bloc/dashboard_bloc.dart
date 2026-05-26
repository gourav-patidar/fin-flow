import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/transaction.dart';
import '../../transactions/data/transaction_repository.dart';
import 'dashboard_calculations.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({
    required TransactionRepository repository,
    DateTime Function()? now,
  })  : _repo = repository,
        _now = now ?? DateTime.now,
        super(const DashboardState.initial()) {
    on<DashboardTransactionsChanged>(_onTransactionsChanged);
    on<DashboardBalanceVisibilityToggled>(_onBalanceVisibilityToggled);

    _subscription = _repo
        .watchTransactions()
        .listen((List<Transaction> txs) => add(DashboardTransactionsChanged(txs)));
  }

  final TransactionRepository _repo;
  final DateTime Function() _now;
  late final StreamSubscription<List<Transaction>> _subscription;

  void _onTransactionsChanged(
    DashboardTransactionsChanged event,
    Emitter<DashboardState> emit,
  ) {
    final DateTime reference = _now();
    final List<Transaction> txs = event.transactions;
    emit(
      state.copyWith(
        status: DashboardStatus.ready,
        totalBalance: DashboardCalculations.totalBalance(txs),
        monthIncome: DashboardCalculations.monthIncome(txs, reference),
        monthExpense: DashboardCalculations.monthExpense(txs, reference),
        categoryBreakdown:
            DashboardCalculations.categoryBreakdown(txs, reference),
        recentTransactions:
            DashboardCalculations.recentTransactions(txs, n: 5),
      ),
    );
  }

  void _onBalanceVisibilityToggled(
    DashboardBalanceVisibilityToggled event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(balanceHidden: !state.balanceHidden));
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
