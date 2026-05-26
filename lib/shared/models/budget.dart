import 'package:hive/hive.dart';

import 'transaction_category.dart';

part 'budget.g.dart';

/// A monthly spending cap for a single [TransactionCategory]. The Analytics
/// screen (Phase 9) renders progress bars from these and warns when
/// [currentSpent] approaches or exceeds [monthlyLimit].
@HiveType(typeId: 4)
class Budget extends HiveObject {
  Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.monthlyLimit,
    required this.currentSpent,
    required this.month,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final TransactionCategory category;

  @HiveField(3)
  final double monthlyLimit;

  /// Mutated as new transactions land. Stored so the dashboard reads it in
  /// O(1) instead of summing all transactions on every rebuild.
  @HiveField(4)
  double currentSpent;

  /// Pinned to the first day of the month this budget covers.
  @HiveField(5)
  final DateTime month;

  double get utilisation =>
      monthlyLimit > 0 ? (currentSpent / monthlyLimit).clamp(0.0, 1.0) : 0.0;

  bool get isOverLimit => currentSpent > monthlyLimit;
}
