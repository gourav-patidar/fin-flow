import 'dart:math';

import '../../features/transactions/data/transaction_repository.dart';
import '../../shared/models/payment_method.dart';
import '../../shared/models/transaction.dart';
import '../../shared/models/transaction_category.dart';
import '../../shared/models/transaction_type.dart';

/// Debug-only helper that wipes the `transactions` store and inserts a
/// realistic 30-row sample using Indian merchants, UPI handles, and
/// categories from `CLAUDE.md` §7.
///
/// Hooked to the dashboard app-bar long-press in [HomePlaceholderScreen]
/// — fires only in `kDebugMode`. Idempotent — safe to call repeatedly.
class SeedService {
  SeedService(this._repo);

  final TransactionRepository _repo;

  Future<void> seed({required String userId, DateTime? now}) async {
    final DateTime origin = now ?? DateTime.now();
    final Random rng = Random(42);
    final List<Transaction> seed = <Transaction>[];

    int id = 1;
    String nextId() => 'seed-${id++}';

    void add({
      required int daysAgo,
      required int hour,
      required int minute,
      required double amount,
      required TransactionType type,
      required TransactionCategory category,
      required String merchant,
      required PaymentMethod method,
      String? note,
    }) {
      final DateTime base = origin.subtract(Duration(days: daysAgo));
      seed.add(
        Transaction(
          id: nextId(),
          userId: userId,
          amount: amount,
          type: type,
          category: category,
          merchant: merchant,
          date: DateTime(base.year, base.month, base.day, hour, minute),
          paymentMethod: method,
          note: note,
        ),
      );
    }

    // Salary — anchor income on the first salary day in window.
    add(
      daysAgo: 25,
      hour: 10,
      minute: 0,
      amount: 84200,
      type: TransactionType.income,
      category: TransactionCategory.investments,
      merchant: 'Salary · TCS',
      method: PaymentMethod.netBanking,
      note: 'Monthly credit',
    );

    // A second smaller income — freelance.
    add(
      daysAgo: 14,
      hour: 16,
      minute: 30,
      amount: 12500,
      type: TransactionType.income,
      category: TransactionCategory.investments,
      merchant: 'Freelance · Razorpay',
      method: PaymentMethod.netBanking,
    );

    // Food / Dining
    final List<({int days, int h, int m, double amt, String merch})> food =
        <({int days, int h, int m, double amt, String merch})>[
      (days: 0, h: 14, m: 15, amt: 420, merch: 'Swiggy'),
      (days: 1, h: 13, m: 22, amt: 285, merch: 'Zomato'),
      (days: 3, h: 21, m: 5, amt: 1840, merch: 'Burma Burma'),
      (days: 7, h: 12, m: 40, amt: 320, merch: 'Chai Point'),
      (days: 12, h: 19, m: 50, amt: 1290, merch: 'Indian Accent'),
    ];
    for (final ({int days, int h, int m, double amt, String merch}) f in food) {
      add(
        daysAgo: f.days,
        hour: f.h,
        minute: f.m,
        amount: f.amt,
        type: TransactionType.expense,
        category: TransactionCategory.foodAndDining,
        merchant: f.merch,
        method: PaymentMethod.upi,
      );
    }

    // Groceries
    add(
      daysAgo: 2,
      hour: 11,
      minute: 0,
      amount: 1450,
      type: TransactionType.expense,
      category: TransactionCategory.groceries,
      merchant: 'BigBasket',
      method: PaymentMethod.upi,
    );
    add(
      daysAgo: 9,
      hour: 9,
      minute: 45,
      amount: 620,
      type: TransactionType.expense,
      category: TransactionCategory.groceries,
      merchant: 'Blinkit',
      method: PaymentMethod.upi,
    );

    // Transport
    add(
      daysAgo: 1,
      hour: 8,
      minute: 30,
      amount: 215,
      type: TransactionType.expense,
      category: TransactionCategory.transport,
      merchant: 'Uber',
      method: PaymentMethod.card,
    );
    add(
      daysAgo: 5,
      hour: 18,
      minute: 10,
      amount: 178,
      type: TransactionType.expense,
      category: TransactionCategory.transport,
      merchant: 'Ola',
      method: PaymentMethod.upi,
    );
    add(
      daysAgo: 20,
      hour: 7,
      minute: 15,
      amount: 3200,
      type: TransactionType.expense,
      category: TransactionCategory.transport,
      merchant: 'IRCTC',
      method: PaymentMethod.card,
      note: 'Bangalore — Mumbai',
    );

    // Bills & Utilities
    add(
      daysAgo: 4,
      hour: 22,
      minute: 12,
      amount: 1840,
      type: TransactionType.expense,
      category: TransactionCategory.billsAndUtilities,
      merchant: 'BSES Electricity',
      method: PaymentMethod.upi,
    );
    add(
      daysAgo: 18,
      hour: 11,
      minute: 0,
      amount: 599,
      type: TransactionType.expense,
      category: TransactionCategory.billsAndUtilities,
      merchant: 'Jio Recharge',
      method: PaymentMethod.upi,
    );
    add(
      daysAgo: 22,
      hour: 10,
      minute: 0,
      amount: 1199,
      type: TransactionType.expense,
      category: TransactionCategory.billsAndUtilities,
      merchant: 'Airtel Fiber',
      method: PaymentMethod.netBanking,
    );

    // Shopping
    add(
      daysAgo: 6,
      hour: 20,
      minute: 0,
      amount: 2350,
      type: TransactionType.expense,
      category: TransactionCategory.shopping,
      merchant: 'Amazon',
      method: PaymentMethod.card,
      note: 'Headphones',
    );
    add(
      daysAgo: 15,
      hour: 17,
      minute: 30,
      amount: 4800,
      type: TransactionType.expense,
      category: TransactionCategory.shopping,
      merchant: 'Myntra',
      method: PaymentMethod.upi,
    );

    // Entertainment
    add(
      daysAgo: 8,
      hour: 21,
      minute: 30,
      amount: 499,
      type: TransactionType.expense,
      category: TransactionCategory.entertainment,
      merchant: 'Netflix',
      method: PaymentMethod.card,
    );
    add(
      daysAgo: 16,
      hour: 19,
      minute: 0,
      amount: 720,
      type: TransactionType.expense,
      category: TransactionCategory.entertainment,
      merchant: 'BookMyShow',
      method: PaymentMethod.upi,
    );

    // Health
    add(
      daysAgo: 10,
      hour: 10,
      minute: 15,
      amount: 1450,
      type: TransactionType.expense,
      category: TransactionCategory.health,
      merchant: 'Apollo Pharmacy',
      method: PaymentMethod.upi,
    );
    add(
      daysAgo: 28,
      hour: 16,
      minute: 0,
      amount: 1800,
      type: TransactionType.expense,
      category: TransactionCategory.health,
      merchant: 'PharmEasy',
      method: PaymentMethod.upi,
    );

    // Investments / Savings
    add(
      daysAgo: 24,
      hour: 11,
      minute: 0,
      amount: 10000,
      type: TransactionType.expense,
      category: TransactionCategory.investments,
      merchant: 'Zerodha SIP',
      method: PaymentMethod.netBanking,
      note: 'Nifty50 Index',
    );
    add(
      daysAgo: 26,
      hour: 11,
      minute: 30,
      amount: 5000,
      type: TransactionType.expense,
      category: TransactionCategory.investments,
      merchant: 'Groww · Mutual Fund',
      method: PaymentMethod.netBanking,
    );

    // UPI peer transfers
    add(
      daysAgo: 1,
      hour: 19,
      minute: 22,
      amount: 1250,
      type: TransactionType.expense,
      category: TransactionCategory.foodAndDining,
      merchant: 'Priya Patel',
      method: PaymentMethod.upi,
      note: 'Split dinner · @okhdfcbank',
    );
    add(
      daysAgo: 11,
      hour: 14,
      minute: 5,
      amount: 750,
      type: TransactionType.expense,
      category: TransactionCategory.entertainment,
      merchant: 'Rohan Mehta',
      method: PaymentMethod.upi,
      note: 'Concert tickets · @paytm',
    );
    add(
      daysAgo: 19,
      hour: 13,
      minute: 50,
      amount: 320,
      type: TransactionType.expense,
      category: TransactionCategory.foodAndDining,
      merchant: 'Ananya Iyer',
      method: PaymentMethod.upi,
      note: 'Cab pool · @ybl',
    );

    // Cashbacks (income, small)
    add(
      daysAgo: 13,
      hour: 9,
      minute: 0,
      amount: 75,
      type: TransactionType.income,
      category: TransactionCategory.shopping,
      merchant: 'CRED Cashback',
      method: PaymentMethod.wallet,
    );
    add(
      daysAgo: 21,
      hour: 9,
      minute: 0,
      amount: 120,
      type: TransactionType.income,
      category: TransactionCategory.foodAndDining,
      merchant: 'Swiggy Money',
      method: PaymentMethod.wallet,
    );

    // A couple of small noise items to round to 30
    add(
      daysAgo: 17,
      hour: 18,
      minute: rng.nextInt(60),
      amount: 60,
      type: TransactionType.expense,
      category: TransactionCategory.foodAndDining,
      merchant: 'Cafe Coffee Day',
      method: PaymentMethod.cash,
    );
    add(
      daysAgo: 23,
      hour: 16,
      minute: rng.nextInt(60),
      amount: 240,
      type: TransactionType.expense,
      category: TransactionCategory.transport,
      merchant: 'Auto · Bangalore',
      method: PaymentMethod.cash,
    );

    await _repo.replaceAll(seed);
  }
}
