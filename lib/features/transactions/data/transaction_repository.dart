import '../../../shared/models/transaction.dart';
import 'transaction_filter.dart';

/// Contract every transaction storage implementation must honor. A future
/// `FirestoreTransactionRepository` will fulfil the exact same surface so
/// swapping the binding is a single-line change.
abstract class TransactionRepository {
  /// Reactive view of the underlying store. Emits an empty list initially,
  /// then a new list after every write. Filter is applied in-memory.
  Stream<List<Transaction>> watchTransactions({
    TransactionFilter filter = const TransactionFilter(),
  });

  Future<List<Transaction>> getAll();

  Future<void> addTransaction(Transaction transaction);

  Future<void> updateTransaction(Transaction transaction);

  Future<void> deleteTransaction(String id);

  /// Bulk replace — used by [SeedService] to drop existing seed data and
  /// insert a fresh batch.
  Future<void> replaceAll(List<Transaction> transactions);
}
