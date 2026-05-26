import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/services/biometric_service.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../data/auth_local_store.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;
  bool _biometricAvailable = false;
  IconData _biometricIcon = Icons.fingerprint_rounded;
  bool _promptedForBiometricThisSession = false;

  static final RegExp _emailPattern =
      RegExp(r'^[\w.+\-]+@[\w\-]+(\.[\w\-]+)+$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocus.requestFocus();
    });
    _probeBiometric();
  }

  Future<void> _probeBiometric() async {
    final BiometricService svc = _biometricService();
    final bool available = await svc.isAvailable();
    if (!mounted) return;
    if (!available) {
      setState(() => _biometricAvailable = false);
      return;
    }
    final List<BiometricType> kinds = await svc.getEnrolledBiometrics();
    if (!mounted) return;
    setState(() {
      _biometricAvailable = true;
      _biometricIcon = kinds.contains(BiometricType.face)
          ? Icons.face_rounded
          : Icons.fingerprint_rounded;
    });
  }

  /// Pulls the BiometricService directly from the AuthBloc's collaborator
  /// graph. A future Phase will register it via DI so this short-cut goes
  /// away.
  BiometricService _biometricService() {
    // The bloc already holds a BiometricService instance; we don't expose it,
    // so for the visibility probe we just instantiate one — the channel name
    // is the same, so isAvailable() answers identically.
    return BiometricService();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  bool _validate() {
    final String email = _email.text.trim();
    final String password = _password.text;
    final String? emailErr = email.isEmpty
        ? 'Enter your email'
        : (!_emailPattern.hasMatch(email) ? 'Enter a valid email' : null);
    final String? pwErr = password.isEmpty
        ? 'Enter your password'
        : (password.length < 6 ? 'Password must be 6+ characters' : null);
    setState(() {
      _emailError = emailErr;
      _passwordError = pwErr;
    });
    return emailErr == null && pwErr == null;
  }

  void _submit() {
    if (!_validate()) return;
    context.read<AuthBloc>().add(
          AuthEmailSignInRequested(
            email: _email.text.trim(),
            password: _password.text,
          ),
        );
  }

  Future<void> _maybePromptToEnableBiometric(AuthAuthenticated state) async {
    if (_promptedForBiometricThisSession) return;
    if (!_biometricAvailable) return;
    if (AuthLocalStore.instance.biometricEnabledForUid == state.user.id) return;

    _promptedForBiometricThisSession = true;
    final bool? enable = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Enable biometric sign-in?'),
        content: const Text(
          'Use Face ID or your fingerprint to sign in next time — '
          'faster than typing your password.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
    if (enable == true) {
      await AuthLocalStore.instance.enableBiometricFor(state.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (BuildContext context, AuthState state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthAuthenticated) {
            _maybePromptToEnableBiometric(state);
          }
        },
        child: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (BuildContext context, AuthState state) {
              final bool isLoading = state is AuthLoading;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.s20,
                  Spacing.s24,
                  Spacing.s20,
                  Spacing.s32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: Spacing.s24),
                    const BrandMark(),
                    const SizedBox(height: Spacing.s20),
                    Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        height: 1.15,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: Spacing.s8),
                    SizedBox(
                      width: 280,
                      child: Text(
                        'Sign in to continue managing your money',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.s24),
                    GlassCard(
                      variant: GlassCardVariant.gradient,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          AppTextField(
                            label: 'Email',
                            hintText: 'you@finflow.app',
                            leadingIcon: Icons.mail_outline_rounded,
                            controller: _email,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            errorText: _emailError,
                          ),
                          const SizedBox(height: Spacing.s16),
                          AppTextField(
                            label: 'Password',
                            hintText: 'Min 6 characters',
                            leadingIcon: Icons.lock_outline_rounded,
                            controller: _password,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            errorText: _passwordError,
                            trailingIcon: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: Spacing.s8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Password reset — coming soon'),
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Spacing.s20),
                    GradientButton(
                      label: 'Sign In',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: isLoading ? null : _submit,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: Spacing.s24),
                    _OrDivider(),
                    const SizedBox(height: Spacing.s20),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: SecondaryButton(
                            label: 'Google',
                            icon: Icon(
                              Icons.g_mobiledata_rounded,
                              color: theme.colorScheme.onSurface,
                            ),
                            onPressed: isLoading
                                ? null
                                : () => context
                                    .read<AuthBloc>()
                                    .add(const AuthGoogleSignInRequested()),
                          ),
                        ),
                        if (_biometricAvailable) ...<Widget>[
                          const SizedBox(width: Spacing.s12),
                          Expanded(
                            child: SecondaryButton(
                              label: 'Biometric',
                              icon: Icon(_biometricIcon),
                              variant: SecondaryButtonVariant.accent,
                              onPressed: isLoading
                                  ? null
                                  : () => context
                                      .read<AuthBloc>()
                                      .add(const AuthBiometricRequested()),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Expanded(child: Divider(color: theme.dividerColor, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.s12),
          child: Text(
            'or continue with',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              letterSpacing: 0.3,
            ),
          ),
        ),
        Expanded(child: Divider(color: theme.dividerColor, height: 1)),
      ],
    );
  }
}
