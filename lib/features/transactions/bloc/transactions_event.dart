import '../../../shared/models/transaction.dart';
import 'transactions_state.dart';

sealed class TransactionsEvent {
  const TransactionsEvent();
}

final class TransactionsDataChanged extends TransactionsEvent {
  const TransactionsDataChanged(this.transactions);
  final List<Transaction> transactions;
}

final class TransactionsSearchChanged extends TransactionsEvent {
  const TransactionsSearchChanged(this.query);
  final String query;
}

final class TransactionsFilterChanged extends TransactionsEvent {
  const TransactionsFilterChanged(this.filter);
  final TxChipFilter filter;
}

final class TransactionsMonthChanged extends TransactionsEvent {
  const TransactionsMonthChanged(this.month);
  final DateTime month;
}

final class TransactionDeleteRequested extends TransactionsEvent {
  const TransactionDeleteRequested(this.id);
  final String id;
}

final class TransactionsCsvExportRequested extends TransactionsEvent {
  const TransactionsCsvExportRequested();
}
