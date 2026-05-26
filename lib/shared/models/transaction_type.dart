import 'package:hive/hive.dart';

part 'transaction_type.g.dart';

/// Cash-flow direction on a [Transaction]. Stored in Hive — DO NOT change
/// the typeId / hiveField indices after first release.
@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income,

  @HiveField(1)
  expense;

  bool get isIncome => this == TransactionType.income;
}
