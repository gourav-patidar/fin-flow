import 'package:flutter/material.dart';

// ─── Shimmer engine ──────────────────────────────────────────────────────────

class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});

  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _position;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _position = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _position,
      builder: (_, Widget? child) {
        final double p = _position.value;
        return ShaderMask(
          shaderCallback: (Rect bounds) => LinearGradient(
            begin: Alignment(p - 1, 0),
            end: Alignment(p + 1, 0),
            colors: isDark
                ? const <Color>[
                    Color(0xFF1C1C28),
                    Color(0xFF2A2A3D),
                    Color(0xFF1C1C28),
                  ]
                : const <Color>[
                    Color(0xFFE2E2EE),
                    Color(0xFFF0F0FA),
                    Color(0xFFE2E2EE),
                  ],
          ).createShader(bounds),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ─── Primitive ───────────────────────────────────────────────────────────────

/// A plain colored rectangle used as a building block for skeletons.
/// Wrap multiple [SkeletonBox]es in a single [_Shimmer] parent for a
/// coherent sweep across the whole placeholder.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE2E2EE),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─── Transaction tile skeleton ────────────────────────────────────────────────

class SkeletonTransactionTile extends StatelessWidget {
  const SkeletonTransactionTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: _Shimmer(
        child: Row(
          children: <Widget>[
            const SkeletonBox(width: 42, height: 42, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SkeletonBox(height: 13, radius: 6),
                  const SizedBox(height: 6),
                  SkeletonBox(
                    width: MediaQuery.sizeOf(context).width * 0.38,
                    height: 11,
                    radius: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const SkeletonBox(width: 64, height: 13, radius: 6),
          ],
        ),
      ),
    );
  }
}

// ─── List skeleton ────────────────────────────────────────────────────────────

class SkeletonTransactionList extends StatelessWidget {
  const SkeletonTransactionList({super.key, this.count = 7});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Section header placeholder
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: _Shimmer(
            child: const SkeletonBox(width: 100, height: 12, radius: 5),
          ),
        ),
        for (int i = 0; i < count; i++) const SkeletonTransactionTile(),
      ],
    );
  }
}

// ─── Analytics skeleton ───────────────────────────────────────────────────────

class SkeletonAnalytics extends StatelessWidget {
  const SkeletonAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 16),
          // Chart card placeholder
          _Shimmer(
            child: Container(
              height: 210,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2A2A3D)
                    : const Color(0xFFE2E2EE),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Insight card placeholder
          _Shimmer(
            child: Container(
              height: 88,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2A2A3D)
                    : const Color(0xFFE2E2EE),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Category bar header
          _Shimmer(
            child: const SkeletonBox(width: 130, height: 12, radius: 5),
          ),
          const SizedBox(height: 14),
          // Category rows
          for (int i = 0; i < 5; i++) ...<Widget>[
            _Shimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const SkeletonBox(width: 32, height: 32, radius: 8),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SkeletonBox(
                              width: (i.isEven ? 100.0 : 80.0),
                              height: 12,
                              radius: 5,
                            ),
                            const SizedBox(height: 6),
                            const SkeletonBox(height: 6, radius: 3),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const SkeletonBox(width: 50, height: 12, radius: 5),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
