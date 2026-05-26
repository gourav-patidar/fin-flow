import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../data/onboarding_preferences.dart';
import 'widgets/onboarding_slide.dart';

class _SlideData {
  const _SlideData({
    required this.eyebrow,
    required this.title,
    required this.titleAccent,
    required this.description,
    required this.icon,
    required this.primaryGlowDark,
    required this.primaryGlowLight,
    this.secondaryGlowDark,
    this.secondaryGlowLight,
    this.accentColor,
  });

  final String eyebrow;
  final String title;
  final String titleAccent;
  final String description;
  final IconData icon;
  final Color primaryGlowDark;
  final Color primaryGlowLight;
  final Color? secondaryGlowDark;
  final Color? secondaryGlowLight;

  /// Override accent color for the title's second line. Slide 3 uses income.
  final Color? accentColor;
}

const List<_SlideData> _slides = <_SlideData>[
  _SlideData(
    eyebrow: 'TRACK',
    title: 'Every rupee.',
    titleAccent: 'Effortlessly tracked.',
    description:
        'Link your bank, UPI and cards. FinFlow auto-categorises every transaction — from your morning chai to your monthly EMI.',
    icon: Icons.account_balance_wallet_rounded,
    primaryGlowDark: AppColorsDark.accent,
    primaryGlowLight: AppColorsLight.accent,
    secondaryGlowDark: AppColorsDark.income,
    secondaryGlowLight: AppColorsLight.income,
  ),
  _SlideData(
    eyebrow: 'UNDERSTAND',
    title: 'Insights that',
    titleAccent: 'actually help.',
    description:
        'Find money leaks before they happen. Get weekly spend reports, budget alerts and personalised tips powered by AI.',
    icon: Icons.pie_chart_rounded,
    primaryGlowDark: AppColorsDark.accent,
    primaryGlowLight: AppColorsLight.accent,
  ),
  _SlideData(
    eyebrow: 'GROW',
    title: 'Reach goals.',
    titleAccent: 'Get rewarded.',
    description:
        'Set goals — a phone, a trip, an emergency fund. Earn XP, build streaks and unlock perks every time you hit a milestone.',
    icon: Icons.emoji_events_rounded,
    primaryGlowDark: AppColorsDark.income,
    primaryGlowLight: AppColorsLight.income,
    secondaryGlowDark: AppColorsDark.accent,
    secondaryGlowLight: AppColorsLight.accent,
    accentColor: AppColorsDark.income,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _slides.length - 1;

  Future<void> _advance() async {
    if (_isLast) {
      await OnboardingPreferences.instance.markSeen();
      if (!mounted) return;
      context.go(Routes.signIn);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _skip() async {
    await OnboardingPreferences.instance.markSeen();
    if (!mounted) return;
    context.go(Routes.signIn);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _TopBar(isLast: _isLast, onSkip: _skip),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (int i) => setState(() => _index = i),
                itemBuilder: (BuildContext context, int i) {
                  final _SlideData s = _slides[i];
                  return OnboardingSlide(
                    eyebrow: s.eyebrow,
                    title: s.title,
                    titleAccent: s.titleAccent,
                    description: s.description,
                    icon: s.icon,
                    primaryGlow:
                        isDark ? s.primaryGlowDark : s.primaryGlowLight,
                    secondaryGlow:
                        isDark ? s.secondaryGlowDark : s.secondaryGlowLight,
                    accentColor: s.accentColor != null
                        ? (isDark
                            ? AppColorsDark.income
                            : AppColorsLight.income)
                        : null,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.s24,
                0,
                Spacing.s24,
                Spacing.s32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _DotIndicator(count: _slides.length, active: _index),
                  const SizedBox(height: Spacing.s20),
                  GradientButton(
                    label: _isLast ? 'Get Started' : 'Continue',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _advance,
                    borderRadius: 18,
                  ),
                  if (_isLast) ...<Widget>[
                    const SizedBox(height: 14),
                    Center(
                      child: GestureDetector(
                        onTap: _skip,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            children: <InlineSpan>[
                              const TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Sign in',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isLast, required this.onSkip});

  final bool isLast;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final List<Color> gradient =
        isDark ? AppColorsDark.gradientHero : AppColorsLight.gradientHero;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.s24,
        Spacing.s8,
        Spacing.s24,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: gradient.first
                          .withValues(alpha: isDark ? 0.4 : 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: Spacing.s8),
              Text(
                'FinFlow',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          if (!isLast)
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.s4,
                  vertical: Spacing.s4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Skip',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color inactive =
        isDark ? AppColorsDark.borderStrong : AppColorsLight.borderStrong;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List<Widget>.generate(count, (int i) {
        final bool isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: EdgeInsets.only(right: i == count - 1 ? 0 : 6),
          height: 6,
          width: isActive ? 28 : 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: isActive ? theme.colorScheme.primary : inactive,
          ),
        );
      }),
    );
  }
}
