import 'package:flutter/material.dart';

import '../../core/constants/radii.dart';
import '../../core/constants/spacing.dart';

/// FinFlow's labeled input. Matches the Sign In design:
/// label above, 52-tall pill with leading/trailing icons, and a 4px accent
/// halo on focus.
///
/// Pass a [controller] for managed text; otherwise the field is uncontrolled
/// and emits [onChanged]. [errorText] turns the border red and shows inline
/// error text — preferred over SnackBars for form validation.
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.hintText,
    this.leadingIcon,
    this.trailingIcon,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
    this.autofocus = false,
    this.errorText,
    this.textInputAction,
    this.focusNode,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final IconData? leadingIcon;
  final Widget? trailingIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool autofocus;
  final String? errorText;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final bool hasError = widget.errorText != null;
    final Color accent = theme.colorScheme.primary;
    final Color iconColor = hasError
        ? theme.colorScheme.error
        : _focused
            ? accent
            : theme.colorScheme.onSurface.withValues(alpha: 0.4);

    final Color fieldBg = isDark
        ? const Color(0xFF232334) // cardElevated dark
        : theme.colorScheme.surface;
    final Color borderColor = hasError
        ? theme.colorScheme.error
        : _focused
            ? accent
            : theme.dividerColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: Spacing.s8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(Radii.button),
            border: Border.all(color: borderColor, width: _focused ? 1.5 : 1),
            boxShadow: _focused && !hasError
                ? <BoxShadow>[
                    BoxShadow(
                      color: accent.withValues(alpha: isDark ? 0.15 : 0.10),
                      blurRadius: 0,
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.s16),
          height: 52,
          child: Row(
            children: <Widget>[
              if (widget.leadingIcon != null) ...<Widget>[
                Icon(widget.leadingIcon, color: iconColor, size: 18),
                const SizedBox(width: Spacing.s12),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.35),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              if (widget.trailingIcon != null) ...<Widget>[
                const SizedBox(width: Spacing.s12),
                widget.trailingIcon!,
              ],
            ],
          ),
        ),
        if (hasError) ...<Widget>[
          const SizedBox(height: Spacing.s4),
          Padding(
            padding: const EdgeInsets.only(left: Spacing.s4),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
