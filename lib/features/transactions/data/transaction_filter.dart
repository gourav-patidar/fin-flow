import '../../../shared/models/transaction_category.dart';
import '../../../shared/models/transaction_type.dart';

/// Filter passed to [TransactionRepository.watchTransactions]. Each field
/// is optional and combined with AND semantics.
class TransactionFilter {
  const TransactionFilter({
    this.category,
    this.type,
    this.from,
    this.to,
    this.query,
  });

  final TransactionCategory? category;
  final TransactionType? type;
  final DateTime? from;
  final DateTime? to;

  /// Case-insensitive substring match against merchant + note.
  final String? query;

  bool get isEmpty =>
      category == null && type == null && from == null && to == null &&
      (query == null || query!.isEmpty);

  TransactionFilter copyWith({
    TransactionCategory? category,
    TransactionType? type,
    DateTime? from,
    DateTime? to,
    String? query,
    bool clearCategory = false,
    bool clearType = false,
    bool clearRange = false,
  }) {
    return TransactionFilter(
      category: clearCategory ? null : (category ?? this.category),
      type: clearType ? null : (type ?? this.type),
      from: clearRange ? null : (from ?? this.from),
      to: clearRange ? null : (to ?? this.to),
      query: query ?? this.query,
    );
  }
}
