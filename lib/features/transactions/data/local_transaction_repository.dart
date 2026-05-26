import 'dart:async';

import 'package:hive/hive.dart';

import '../../../shared/models/transaction.dart';
import 'transaction_filter.dart';
import 'transaction_repository.dart';

/// Local-only implementation. Swap to FirestoreTransactionRepository when
/// backend is configured. The interface contract is identical.
///
/// Single Hive box `transactions`. Writes go through this class so the
/// broadcast controller can fan out updates to every watcher.
class LocalTransactionRepository implements TransactionRepository {
  LocalTransactionRepository(this._box);

  static const String boxName = 'transactions';

  final Box<Transaction> _box;
  final StreamController<void> _changes =
      StreamController<void>.broadcast();

  @override
  Stream<List<Transaction>> watchTransactions({
    TransactionFilter filter = const TransactionFilter(),
  }) async* {
    // Emit current snapshot once, then re-emit after every write.
    yield _snapshot(filter);
    await for (final void _ in _changes.stream) {
      yield _snapshot(filter);
    }
  }

  @override
  Future<List<Transaction>> getAll() async => _snapshot(const TransactionFilter());

  @override
  Future<void> addTransaction(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
    _changes.add(null);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
    _changes.add(null);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
    _changes.add(null);
  }

  @override
  Future<void> replaceAll(List<Transaction> transactions) async {
    await _box.clear();
    final Map<String, Transaction> byId = <String, Transaction>{
      for (final Transaction t in transactions) t.id: t,
    };
    await _box.putAll(byId);
    _changes.add(null);
  }

  List<Transaction> _snapshot(TransactionFilter filter) {
    final Iterable<Transaction> all = _box.values;
    final List<Transaction> filtered = all.where((Transaction t) {
      if (filter.category != null && t.category != filter.category) {
        return false;
      }
      if (filter.type != null && t.type != filter.type) {
        return false;
      }
      if (filter.from != null && t.date.isBefore(filter.from!)) {
        return false;
      }
      if (filter.to != null && t.date.isAfter(filter.to!)) {
        return false;
      }
      final String? q = filter.query?.trim().toLowerCase();
      if (q != null && q.isNotEmpty) {
        final String haystack =
            '${t.merchant} ${t.note ?? ''}'.toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      return true;
    }).toList()
      ..sort((Transaction a, Transaction b) => b.date.compareTo(a.date));
    return filtered;
  }

  Future<void> dispose() async {
    await _changes.close();
  }
}
