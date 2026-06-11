import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class AuthButtonsWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onPhoneLogin;

  const AuthButtonsWidget({
    required this.isLoading,
    required this.onGoogleSignIn,
    required this.onPhoneLogin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Google Sign-In ─────────────────────────────────────────────────
        SizedBox(
          height: 52,
          child: OutlinedButton(
            onPressed: isLoading ? null : onGoogleSignIn,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 1.5,
              ),
              backgroundColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Real Google "G" logo painted with correct brand colours
                      const _GoogleLogo(size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Continue with Google',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // ── Divider ────────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Divider(color: theme.colorScheme.outlineVariant),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'or',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: theme.colorScheme.outlineVariant),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Phone OTP ──────────────────────────────────────────────────────
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPhoneLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'phone_android',
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Continue with Phone OTP',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Google "G" logo — drawn with correct brand colours via CustomPainter
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    // Background circle — white
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = Colors.white,
    );

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // ── Draw the four coloured arc segments ─────────────────────────────

    // Red — top-right (330° → 60°)
    _drawArc(canvas, rect, _deg(330), _deg(90),
        const Color(0xFFEA4335), size);

    // Yellow — right (60° → 150°)
    _drawArc(canvas, rect, _deg(60), _deg(90),
        const Color(0xFFFBBC05), size);

    // Green — bottom (150° → 270°)
    _drawArc(canvas, rect, _deg(150), _deg(120),
        const Color(0xFF34A853), size);

    // Blue — left (270° → 330°)
    _drawArc(canvas, rect, _deg(270), _deg(60),
        const Color(0xFF4285F4), size);

    // ── White inner circle (donut cutout) ────────────────────────────────
    final innerR = r * 0.60;
    canvas.drawCircle(
      Offset(cx, cy),
      innerR,
      Paint()..color = Colors.white,
    );

    // ── Blue horizontal bar (the crossbar of the "G") ────────────────────
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barLeft = cx; // starts at centre
    final barRight = cx + r; // extends to right edge
    final barTop = cy - r * 0.13;
    final barBottom = cy + r * 0.13;

    canvas.drawRect(
      Rect.fromLTRB(barLeft, barTop, barRight, barBottom),
      barPaint,
    );

    // White circle again to clip inner area of bar
    canvas.drawCircle(
      Offset(cx, cy),
      innerR,
      Paint()..color = Colors.white,
    );

    // ── Outer clip: ensure nothing escapes the circle ────────────────────
    // (already handled by arc drawing, but belt-and-suspenders)
  }

  void _drawArc(Canvas canvas, Rect rect, double startAngle, double sweep,
      Color color, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(rect.center.dx, rect.center.dy)
      ..arcTo(rect, startAngle, sweep, false)
      ..close();

    canvas.drawPath(path, paint);
  }

  double _deg(double degrees) => degrees * (3.14159265358979 / 180);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
