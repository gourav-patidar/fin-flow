import 'package:hive/hive.dart';

import 'payment_method.dart';
import 'transaction_category.dart';
import 'transaction_type.dart';

part 'transaction.g.dart';

/// A single money movement — the core record of FinFlow.
///
/// Stored in Hive box `transactions`. Field indices are STABLE across
/// releases — adding new fields gets a new index; never reuse or renumber
/// existing ones, or stored data becomes unreadable.
@HiveType(typeId: 3)
class Transaction extends HiveObject {
  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.merchant,
    required this.date,
    required this.paymentMethod,
    this.note,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  /// Stored as a positive number; direction is conveyed via [type].
  @HiveField(2)
  final double amount;

  @HiveField(3)
  final TransactionType type;

  @HiveField(4)
  final TransactionCategory category;

  @HiveField(5)
  final String merchant;

  @HiveField(6)
  final String? note;

  @HiveField(7)
  final DateTime date;

  @HiveField(8)
  final PaymentMethod paymentMethod;

  /// Signed amount — positive for income, negative for expense. Convenience
  /// for analytics and the dashboard balance calc.
  double get signedAmount =>
      type == TransactionType.income ? amount : -amount;

  Transaction copyWith({
    String? id,
    String? userId,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    String? merchant,
    String? note,
    DateTime? date,
    PaymentMethod? paymentMethod,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      merchant: merchant ?? this.merchant,
      note: note ?? this.note,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
