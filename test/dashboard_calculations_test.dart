import 'package:flutter_test/flutter_test.dart';

import 'package:finflow/features/dashboard/bloc/dashboard_calculations.dart';
import 'package:finflow/shared/models/payment_method.dart';
import 'package:finflow/shared/models/transaction.dart';
import 'package:finflow/shared/models/transaction_category.dart';
import 'package:finflow/shared/models/transaction_type.dart';

Transaction _tx({
  required String id,
  required double amount,
  required TransactionType type,
  required DateTime date,
  TransactionCategory category = TransactionCategory.foodAndDining,
  PaymentMethod paymentMethod = PaymentMethod.upi,
}) {
  return Transaction(
    id: id,
    userId: 'user-1',
    amount: amount,
    type: type,
    category: category,
    merchant: 'Test',
    date: date,
    paymentMethod: paymentMethod,
  );
}

void main() {
  final DateTime now = DateTime(2026, 5, 26, 12, 0);

  group('DashboardCalculations.totalBalance', () {
    test('empty list returns 0', () {
      expect(DashboardCalculations.totalBalance(const <Transaction>[]), 0);
    });

    test('only income sums positive', () {
      final List<Transaction> txs = <Transaction>[
        _tx(id: 'a', amount: 1000, type: TransactionType.income, date: now),
        _tx(id: 'b', amount: 500, type: TransactionType.income, date: now),
      ];
      expect(DashboardCalculations.totalBalance(txs), 1500);
    });

    test('only expense sums negative', () {
      final List<Transaction> txs = <Transaction>[
        _tx(id: 'a', amount: 200, type: TransactionType.expense, date: now),
        _tx(id: 'b', amount: 50, type: TransactionType.expense, date: now),
      ];
      expect(DashboardCalculations.totalBalance(txs), -250);
    });

    test('mixed income + expense nets correctly', () {
      final List<Transaction> txs = <Transaction>[
        _tx(id: 'a', amount: 1000, type: TransactionType.income, date: now),
        _tx(id: 'b', amount: 300, type: TransactionType.expense, date: now),
        _tx(id: 'c', amount: 200, type: TransactionType.expense, date: now),
      ];
      expect(DashboardCalculations.totalBalance(txs), 500);
    });
  });

  group('DashboardCalculations.monthIncome / monthExpense', () {
    test('only this-month entries are counted', () {
      final List<Transaction> txs = <Transaction>[
        _tx(
          id: 'this',
          amount: 1000,
          type: TransactionType.income,
          date: DateTime(2026, 5, 10),
        ),
        _tx(
          id: 'prev',
          amount: 9000,
          type: TransactionType.income,
          date: DateTime(2026, 4, 28),
        ),
        _tx(
          id: 'next',
          amount: 200,
          type: TransactionType.expense,
          date: DateTime(2026, 6, 1),
        ),
        _tx(
          id: 'this-exp',
          amount: 150,
          type: TransactionType.expense,
          date: DateTime(2026, 5, 18),
        ),
      ];
      expect(DashboardCalculations.monthIncome(txs, now), 1000);
      expect(DashboardCalculations.monthExpense(txs, now), 150);
    });
  });

  group('DashboardCalculations.categoryBreakdown', () {
    test('aggregates this-month expenses and omits zero categories', () {
      final List<Transaction> txs = <Transaction>[
        _tx(
          id: 'a',
          amount: 420,
          type: TransactionType.expense,
          category: TransactionCategory.foodAndDining,
          date: DateTime(2026, 5, 20),
        ),
        _tx(
          id: 'b',
          amount: 285,
          type: TransactionType.expense,
          category: TransactionCategory.foodAndDining,
          date: DateTime(2026, 5, 22),
        ),
        _tx(
          id: 'c',
          amount: 1840,
          type: TransactionType.expense,
          category: TransactionCategory.billsAndUtilities,
          date: DateTime(2026, 5, 18),
        ),
        // Different month — must NOT count.
        _tx(
          id: 'd',
          amount: 99,
          type: TransactionType.expense,
          category: TransactionCategory.foodAndDining,
          date: DateTime(2026, 4, 30),
        ),
        // Income — must NOT count.
        _tx(
          id: 'e',
          amount: 1000,
          type: TransactionType.income,
          category: TransactionCategory.investments,
          date: DateTime(2026, 5, 1),
        ),
      ];
      final Map<TransactionCategory, double> breakdown =
          DashboardCalculations.categoryBreakdown(txs, now);
      expect(breakdown[TransactionCategory.foodAndDining], 705);
      expect(breakdown[TransactionCategory.billsAndUtilities], 1840);
      expect(breakdown.containsKey(TransactionCategory.investments), isFalse);
    });
  });

  group('DashboardCalculations.recentTransactions', () {
    test('returns the n most-recent items in desc date order', () {
      final List<Transaction> txs = <Transaction>[
        _tx(
          id: 'old',
          amount: 1,
          type: TransactionType.expense,
          date: DateTime(2026, 1, 1),
        ),
        _tx(
          id: 'mid',
          amount: 2,
          type: TransactionType.expense,
          date: DateTime(2026, 3, 15),
        ),
        _tx(
          id: 'new',
          amount: 3,
          type: TransactionType.expense,
          date: DateTime(2026, 5, 20),
        ),
      ];
      final List<Transaction> recent =
          DashboardCalculations.recentTransactions(txs, n: 2);
      expect(recent.map((Transaction t) => t.id).toList(), <String>['new', 'mid']);
    });
  });
}
