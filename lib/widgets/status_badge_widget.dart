import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum BadgeStatus { pending, approved, rejected, verified, applied, underReview }

class StatusBadgeWidget extends StatelessWidget {
  final BadgeStatus status;
  final String? customLabel;
  final bool compact;

  const StatusBadgeWidget({
    required this.status,
    this.customLabel,
    this.compact = false,
    super.key,
  });

  _BadgeStyle _getStyle(BuildContext context) {
    switch (status) {
      case BadgeStatus.approved:
      case BadgeStatus.verified:
        return _BadgeStyle(
          bg: const Color(0xFFE8F5E9),
          text: const Color(0xFF1B5E20),
          label:
              customLabel ??
              (status == BadgeStatus.verified ? 'Verified' : 'Approved'),
          icon: '✓',
        );
      case BadgeStatus.pending:
        return _BadgeStyle(
          bg: const Color(0xFFFFF8E1),
          text: const Color(0xFFE65100),
          label: customLabel ?? 'Pending',
          icon: '⏳',
        );
      case BadgeStatus.rejected:
        return _BadgeStyle(
          bg: const Color(0xFFFFEBEE),
          text: const Color(0xFFB71C1C),
          label: customLabel ?? 'Rejected',
          icon: '✕',
        );
      case BadgeStatus.applied:
        return _BadgeStyle(
          bg: const Color(0xFFE3F2FD),
          text: const Color(0xFF0D47A1),
          label: customLabel ?? 'Applied',
          icon: '→',
        );
      case BadgeStatus.underReview:
        return _BadgeStyle(
          bg: const Color(0xFFF3E5F5),
          text: const Color(0xFF4A148C),
          label: customLabel ?? 'Under Review',
          icon: '◎',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStyle(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        style.label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w600,
          color: style.text,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _BadgeStyle {
  final Color bg;
  final Color text;
  final String label;
  final String icon;
  const _BadgeStyle({
    required this.bg,
    required this.text,
    required this.label,
    required this.icon,
  });
}
