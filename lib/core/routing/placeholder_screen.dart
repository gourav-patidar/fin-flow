import 'package:flutter/material.dart';

/// Temporary screen used during Phase 0 to verify routing + theming. Each
/// real screen replaces its usage in later phases.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.routeName, super.key});

  final String routeName;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(routeName)),
      body: Center(
        child: Text(
          routeName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
