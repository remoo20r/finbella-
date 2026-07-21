import 'dart:io';

import 'package:flutter/material.dart';

/// App-wide backdrop, painted in code (no image asset): a deep black base with
/// glowing diagonal light-streaks in red / magenta / violet, plus soft corner
/// blooms and a subtle vignette. Shared by every route (see app_router) so the
/// whole app has one cohesive, premium look. A gentle dark scrim keeps
/// foreground text readable over the brighter streaks.
///
/// The painter runs once (cached via RepaintBoundary + shouldRepaint=false)
/// and uses fewer, lighter streaks on Android so it stays cheap on low-end
/// TV boxes.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFF050507)),
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: _StreaksPainter(lite: Platform.isAndroid)),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x33000000), Color(0x99000000)],
            ),
          ),
          child: SizedBox.expand(),
        ),
        child,
      ],
    );
  }
}

class _StreaksPainter extends CustomPainter {
  const _StreaksPainter({this.lite = false});

  /// Lighter variant (fewer streaks, smaller blur) for low-end Android.
  final bool lite;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _bloom(canvas, Offset(w * 0.08, h * 0.02), h * 0.7,
        const Color(0xFF6A2AD6), 0.30);
    _bloom(canvas, Offset(w * 0.95, h * 1.0), h * 0.8,
        const Color(0xFFE01E4B), 0.28);
    _bloom(canvas, Offset(w * 0.5, h * 0.5), h * 0.55,
        const Color(0xFF2A1550), 0.22);

    final streaks = lite
        ? const <_Streak>[
            _Streak(0.02, 6, Color(0xFFFF2D55), 0.85),
            _Streak(0.18, 9, Color(0xFFB01E5A), 0.65),
            _Streak(0.42, 6, Color(0xFFE01E4B), 0.70),
            _Streak(0.66, 8, Color(0xFF7A1FA2), 0.55),
            _Streak(0.88, 5, Color(0xFFC03AD6), 0.45),
          ]
        : const <_Streak>[
            _Streak(0.02, 6, Color(0xFFFF2D55), 0.9),
            _Streak(0.10, 3, Color(0xFFFF5A6A), 0.5),
            _Streak(0.18, 10, Color(0xFFB01E5A), 0.7),
            _Streak(0.30, 4, Color(0xFF8A2BE2), 0.5),
            _Streak(0.42, 7, Color(0xFFE01E4B), 0.75),
            _Streak(0.55, 3, Color(0xFFFF7A8A), 0.4),
            _Streak(0.66, 9, Color(0xFF7A1FA2), 0.6),
            _Streak(0.78, 5, Color(0xFFFF2D55), 0.7),
            _Streak(0.88, 3, Color(0xFFC03AD6), 0.45),
            _Streak(0.96, 7, Color(0xFFE01E4B), 0.6),
          ];

    final diag = (w + h);
    for (final s in streaks) {
      final cx = w * s.pos;
      final start = Offset(cx - diag * 0.5, h + diag * 0.1);
      final end = Offset(cx + diag * 0.5, -diag * 0.1);

      final paint = Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = s.width
        ..blendMode = BlendMode.plus
        ..shader = LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            s.color.withValues(alpha: 0.0),
            s.color.withValues(alpha: s.opacity),
            s.color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromPoints(start, end))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.width * (lite ? 0.6 : 0.9));

      canvas.drawLine(start, end, paint);
    }
  }

  void _bloom(Canvas canvas, Offset center, double radius, Color color, double alpha) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _StreaksPainter oldDelegate) => false;
}

class _Streak {
  const _Streak(this.pos, this.width, this.color, this.opacity);

  final double pos;
  final double width;
  final Color color;
  final double opacity;
}
