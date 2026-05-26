import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/di/app_locator.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/models/payment_method.dart';
import '../../../../shared/models/transaction.dart';
import '../../../../shared/models/transaction_category.dart';
import '../../../../shared/models/transaction_type.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/category_icon.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../transactions/data/transaction_repository.dart';

/// Modal bottom sheet for creating a new [Transaction]. Returns `true` if
/// a transaction was persisted, `null`/`false` if the user dismissed.
class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({required this.userId, super.key});

  final String userId;

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();

  static Future<bool?> show(BuildContext context, {required String userId}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddTransactionSheet(userId: userId),
    );
  }
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  TransactionType _type = TransactionType.expense;
  TransactionCategory _category = TransactionCategory.foodAndDining;
  PaymentMethod _paymentMethod = PaymentMethod.upi;
  DateTime _date = DateTime.now();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _merchant = TextEditingController();
  final TextEditingController _note = TextEditingController();
  bool _saving = false;
  String? _amountError;
  String? _merchantError;

  @override
  void dispose() {
    _amount.dispose();
    _merchant.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String amountStr = _amount.text.trim();
    final double? amount = double.tryParse(amountStr);
    final String merchant = _merchant.text.trim();

    setState(() {
      _amountError = (amount == null || amount <= 0)
          ? 'Enter an amount > 0'
          : null;
      _merchantError = merchant.isEmpty ? 'Enter a merchant' : null;
    });
    if (_amountError != null || _merchantError != null) return;

    setState(() => _saving = true);
    final Transaction tx = Transaction(
      id: 'tx-${DateTime.now().microsecondsSinceEpoch}',
      userId: widget.userId,
      amount: amount!,
      type: _type,
      category: _category,
      merchant: merchant,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      date: _date,
      paymentMethod: _paymentMethod,
    );
    await locator<TransactionRepository>().addTransaction(tx);
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(true);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData mq = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            Spacing.s20,
            Spacing.s16,
            Spacing.s20,
            Spacing.s24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.s16),
              Text(
                'Add transaction',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: Spacing.s20),
              _TypeToggle(
                value: _type,
                onChanged: (TransactionType t) => setState(() => _type = t),
              ),
              const SizedBox(height: Spacing.s20),
              AppTextField(
                label: 'Amount',
                hintText: '0',
                leadingIcon: Icons.currency_rupee_rounded,
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                errorText: _amountError,
              ),
              const SizedBox(height: Spacing.s16),
              AppTextField(
                label: 'Merchant',
                hintText: 'e.g. Swiggy, BSES, Aarav Sharma',
                leadingIcon: Icons.store_rounded,
                controller: _merchant,
                errorText: _merchantError,
              ),
              const SizedBox(height: Spacing.s16),
              _CategoryPicker(
                value: _category,
                onChanged: (TransactionCategory c) =>
                    setState(() => _category = c),
              ),
              const SizedBox(height: Spacing.s16),
              _PaymentPicker(
                value: _paymentMethod,
                onChanged: (PaymentMethod m) =>
                    setState(() => _paymentMethod = m),
              ),
              const SizedBox(height: Spacing.s16),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(14),
                    color: theme.cardTheme.color,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.event_rounded,
                        size: 18,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: Spacing.s12),
                      Expanded(
                        child: Text(
                          'Date · ${formatRelativeDate(_date)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.s16),
              AppTextField(
                label: 'Note (optional)',
                hintText: 'Anything to remember?',
                leadingIcon: Icons.notes_rounded,
                controller: _note,
              ),
              const SizedBox(height: Spacing.s24),
              GradientButton(
                label: _saving ? 'Saving…' : 'Save transaction',
                icon: Icons.check_rounded,
                onPressed: _saving ? null : _save,
                isLoading: _saving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.value, required this.onChanged});
  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    Widget pill(TransactionType t, String label, IconData icon) {
      final bool active = value == t;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 44,
            decoration: BoxDecoration(
              color: active
                  ? theme.colorScheme.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  size: 16,
                  color: active
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          pill(TransactionType.expense, 'Expense', Icons.arrow_upward_rounded),
          pill(TransactionType.income, 'Income', Icons.arrow_downward_rounded),
        ],
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({required this.value, required this.onChanged});
  final TransactionCategory value;
  final ValueChanged<TransactionCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Category',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: Spacing.s8),
        SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: TransactionCategory.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: Spacing.s12),
            itemBuilder: (BuildContext context, int i) {
              final TransactionCategory c = TransactionCategory.values[i];
              final bool active = c == value;
              return GestureDetector(
                onTap: () => onChanged(c),
                child: SizedBox(
                  width: 72,
                  child: Column(
                    children: <Widget>[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: active
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: CategoryIcon(category: c),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        c.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: active
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PaymentPicker extends StatelessWidget {
  const _PaymentPicker({required this.value, required this.onChanged});
  final PaymentMethod value;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Paid via',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: Spacing.s8),
        Wrap(
          spacing: Spacing.s8,
          runSpacing: Spacing.s8,
          children: <Widget>[
            for (final PaymentMethod m in PaymentMethod.values)
              _chip(theme, m),
          ],
        ),
      ],
    );
  }

  Widget _chip(ThemeData theme, PaymentMethod m) {
    final bool active = m == value;
    return GestureDetector(
      onTap: () => onChanged(m),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: Spacing.s12, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : theme.cardTheme.color,
          border: Border.all(
            color: active
                ? theme.colorScheme.primary
                : theme.dividerColor,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          m.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
