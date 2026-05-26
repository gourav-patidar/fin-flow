import 'package:hive/hive.dart';

part 'payment_method.g.dart';

/// How a transaction was paid for. Stored in Hive — DO NOT renumber.
@HiveType(typeId: 1)
enum PaymentMethod {
  @HiveField(0)
  upi('UPI'),

  @HiveField(1)
  card('Card'),

  @HiveField(2)
  netBanking('Net Banking'),

  @HiveField(3)
  wallet('Wallet'),

  @HiveField(4)
  cash('Cash');

  const PaymentMethod(this.label);
  final String label;
}
