import 'package:hive/hive.dart';

part 'transaction_category.g.dart';

/// The 8 canonical transaction categories from `CLAUDE.md` §7. Stored in
/// Hive — the integer typeId / hiveField indices must NEVER be reordered
/// or renumbered after the first release.
@HiveType(typeId: 2)
enum TransactionCategory {
  @HiveField(0)
  foodAndDining('Food & Dining'),

  @HiveField(1)
  groceries('Groceries'),

  @HiveField(2)
  transport('Transport'),

  @HiveField(3)
  billsAndUtilities('Bills & Utilities'),

  @HiveField(4)
  shopping('Shopping'),

  @HiveField(5)
  entertainment('Entertainment'),

  @HiveField(6)
  health('Health'),

  @HiveField(7)
  investments('Investments');

  const TransactionCategory(this.label);
  final String label;

  static TransactionCategory? tryParse(String value) {
    for (final TransactionCategory c in TransactionCategory.values) {
      if (c.label == value) return c;
    }
    return null;
  }
}
