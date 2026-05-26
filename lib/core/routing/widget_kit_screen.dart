import 'package:flutter/material.dart';

import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/category_icon.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/secondary_button.dart';
import '../../shared/widgets/section_header.dart';
import '../constants/spacing.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

/// Temporary `/kit` route showing every Phase-1 widget in both themes for
/// visual review. Remove from the router once design sign-off is complete.
class WidgetKitScreen extends StatelessWidget {
  const WidgetKitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Kit')),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Spacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _Section(
                title: 'Formatters',
                child: _FormattersDemo(),
              ),
              SizedBox(height: Spacing.s24),
              _Section(
                title: 'GlassCard — flat',
                child: GlassCard(
                  child: Text('Flat surface — list containers, settings'),
                ),
              ),
              SizedBox(height: Spacing.s16),
              _Section(
                title: 'GlassCard — gradient',
                child: GlassCard(
                  variant: GlassCardVariant.gradient,
                  child: Text('Gradient surface — Sign In form card'),
                ),
              ),
              SizedBox(height: Spacing.s24),
              _Section(
                title: 'Buttons',
                child: _ButtonsDemo(),
              ),
              SizedBox(height: Spacing.s24),
              _Section(
                title: 'Inputs',
                child: _InputsDemo(),
              ),
              SizedBox(height: Spacing.s24),
              _Section(
                title: 'Section header',
                child: SectionHeader(
                  title: 'Recent activity',
                  actionLabel: 'See all',
                ),
              ),
              SizedBox(height: Spacing.s24),
              _Section(
                title: 'Category icons',
                child: _CategoryGrid(),
              ),
              SizedBox(height: Spacing.s32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: Spacing.s12),
        child,
      ],
    );
  }
}

class _FormattersDemo extends StatelessWidget {
  const _FormattersDemo();

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('formatINR(284650, decimals: 2)  →  ${formatINR(284650, decimals: 2)}'),
          Text('formatINR(-420)  →  ${formatINR(-420)}'),
          Text('formatINR(12345678)  →  ${formatINR(12345678)}'),
          const SizedBox(height: Spacing.s8),
          Text('formatRelativeDate(today)  →  ${formatRelativeDate(now)}'),
          Text(
            'formatRelativeDate(yesterday)  →  '
            '${formatRelativeDate(now.subtract(const Duration(days: 1)))}',
          ),
          Text(
            'formatRelativeDate(60d ago)  →  '
            '${formatRelativeDate(now.subtract(const Duration(days: 60)))}',
          ),
        ],
      ),
    );
  }
}

class _ButtonsDemo extends StatelessWidget {
  const _ButtonsDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GradientButton(
          label: 'Sign In',
          icon: Icons.arrow_forward_rounded,
          onPressed: () {},
        ),
        const SizedBox(height: Spacing.s12),
        GradientButton(
          label: 'Loading',
          isLoading: true,
          onPressed: () {},
        ),
        const SizedBox(height: Spacing.s12),
        Row(
          children: <Widget>[
            Expanded(
              child: SecondaryButton(
                label: 'Google',
                icon: Icon(Icons.g_mobiledata_rounded),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: Spacing.s12),
            Expanded(
              child: SecondaryButton(
                label: 'Biometric',
                icon: Icon(Icons.fingerprint_rounded),
                variant: SecondaryButtonVariant.accent,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InputsDemo extends StatelessWidget {
  const _InputsDemo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        AppTextField(
          label: 'Email',
          hintText: 'you@finflow.app',
          leadingIcon: Icons.mail_outline_rounded,
        ),
        SizedBox(height: Spacing.s16),
        AppTextField(
          label: 'Password',
          hintText: '••••••••',
          leadingIcon: Icons.lock_outline_rounded,
          obscureText: true,
        ),
        SizedBox(height: Spacing.s16),
        AppTextField(
          label: 'Amount',
          hintText: '0',
          leadingIcon: Icons.currency_rupee_rounded,
          errorText: 'Amount must be greater than 0',
        ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Wrap(
        spacing: Spacing.s16,
        runSpacing: Spacing.s16,
        children: TransactionCategory.values.map((TransactionCategory c) {
          return SizedBox(
            width: 72,
            child: Column(
              children: <Widget>[
                CategoryIcon(category: c),
                const SizedBox(height: Spacing.s8),
                Text(
                  c.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
