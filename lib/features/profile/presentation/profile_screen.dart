import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/app_locator.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_event.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../../../features/dashboard/presentation/widgets/bottom_nav.dart';
import '../../../features/transactions/data/transaction_repository.dart';
import '../../../shared/models/app_user.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (_) => ProfileBloc(
        repository: locator<TransactionRepository>(),
        themeNotifier: locator<ValueNotifier<ThemeMode>>(),
      ),
      child: const _ProfileView(),
    );
  }
}

// ─── Main view ───────────────────────────────────────────────────────────────

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final AppUser? user =
        authState is AuthAuthenticated ? authState.user : null;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (prev, next) =>
          next.exportStatus != prev.exportStatus,
      listener: (context, state) {
        if (state.exportStatus == ProfileExportStatus.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export shared successfully'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.exportStatus == ProfileExportStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Export failed'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Column(
            children: <Widget>[
              _HeroHeader(user: user),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: <Widget>[
                    const SizedBox(height: 20),
                    _StatsStrip(state: state),
                    const SizedBox(height: 28),
                    _SectionLabel('Appearance'),
                    const SizedBox(height: 8),
                    _SettingsCard(children: [_ThemeTile(state: state)]),
                    const SizedBox(height: 20),
                    _SectionLabel('Security'),
                    const SizedBox(height: 8),
                    _SettingsCard(children: [
                      _BiometricTile(state: state, uid: user?.id),
                    ]),
                    const SizedBox(height: 20),
                    _SectionLabel('Data'),
                    const SizedBox(height: 8),
                    _SettingsCard(children: [
                      _ExportTile(
                        icon: Icons.picture_as_pdf_rounded,
                        label: 'Export PDF Statement',
                        isLoading:
                            state.exportStatus == ProfileExportStatus.loading,
                        onTap: () => context
                            .read<ProfileBloc>()
                            .add(const ProfileExportPdfRequested()),
                      ),
                      _Divider(),
                      _ExportTile(
                        icon: Icons.table_chart_rounded,
                        label: 'Export CSV',
                        isLoading:
                            state.exportStatus == ProfileExportStatus.loading,
                        onTap: () => context
                            .read<ProfileBloc>()
                            .add(const ProfileExportCsvRequested()),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _SectionLabel('Account'),
                    const SizedBox(height: 8),
                    _SettingsCard(children: [
                      _SignOutTile(),
                    ]),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const BottomNav(),
            ],
          ),
        );
      },
    );
  }
}

// ─── Hero header ─────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color accent = theme.colorScheme.primary;

    final String name = user?.displayName ?? 'You';
    final String email = user?.email ?? '';
    final String initials = _initials(name);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Avatar
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? const <Color>[
                            Color(0xFF7B6EF6),
                            Color(0xFF5B4FE0),
                          ]
                        : const <Color>[
                            Color(0xFF6358E8),
                            Color(0xFF4A3FC9),
                          ],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Name + email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'FinFlow Member',
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length.clamp(1, 2))
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// ─── Stats strip ─────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _StatCard(
            icon: Icons.bolt_rounded,
            iconColor: const Color(0xFFFFB547),
            value: state.xpLabel,
            label: 'XP Points',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFFF5C5C),
            value: state.streakDays.toString(),
            label: 'Day Streak',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.receipt_long_rounded,
            iconColor: const Color(0xFF00D4AA),
            value: state.totalTransactions.toString(),
            label: 'Transactions',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Settings shell ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: theme(context).textTheme.labelSmall?.copyWith(
            color: theme(context).colorScheme.onSurface.withValues(alpha: 0.45),
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  ThemeData theme(BuildContext c) => Theme.of(c);
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: Theme.of(context).dividerColor,
    );
  }
}

// ─── Theme tile ───────────────────────────────────────────────────────────────

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _IconBox(
                icon: Icons.palette_rounded,
                color: accent,
              ),
              const SizedBox(width: 12),
              Text(
                'Theme',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SegmentedButton<ThemeMode>(
            segments: const <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_rounded, size: 17),
                label: Text('Light'),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto_rounded, size: 17),
                label: Text('Auto'),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_rounded, size: 17),
                label: Text('Dark'),
              ),
            ],
            selected: <ThemeMode>{state.themeMode},
            onSelectionChanged: (Set<ThemeMode> s) => context
                .read<ProfileBloc>()
                .add(ProfileThemeChanged(s.first)),
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: accent.withValues(alpha: 0.15),
              selectedForegroundColor: accent,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Biometric tile ───────────────────────────────────────────────────────────

class _BiometricTile extends StatelessWidget {
  const _BiometricTile({required this.state, required this.uid});

  final ProfileState state;
  final String? uid;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          _IconBox(
            icon: Icons.fingerprint_rounded,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Biometric Unlock',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Sign in using fingerprint or face ID',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: state.biometricEnabled,
            onChanged: (val) => context.read<ProfileBloc>().add(
                  ProfileBiometricToggled(enabled: val, uid: uid),
                ),
            activeThumbColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

// ─── Export tile ─────────────────────────────────────────────────────────────

class _ExportTile extends StatelessWidget {
  const _ExportTile({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            _IconBox(
              icon: icon,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Sign-out tile ────────────────────────────────────────────────────────────

class _SignOutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color red = theme.colorScheme.error;

    return InkWell(
      onTap: () => _confirmSignOut(context),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            _IconBox(icon: Icons.logout_rounded, color: red),
            const SizedBox(width: 12),
            Text(
              'Sign Out',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthSignOutRequested());
    }
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 19),
    );
  }
}
