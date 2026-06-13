import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_export.dart';
import '../../../core/app_localizations.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../land_listings_screen/land_listings_screen.dart';

class OwnerContactWidget extends StatelessWidget {
  final LandModel land;
  // true once farmer's application is approved — reveals full contact
  final bool isContactRevealed;
  final String ownerId;

  const OwnerContactWidget({
    required this.land,
    this.isContactRevealed = false,
    required this.ownerId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Show first name only before approval; full name after
    final displayName = isContactRevealed
        ? land.ownerName
        : '${land.ownerName.split(' ').first} ••••';

    final initial = land.ownerName.isNotEmpty
        ? land.ownerName[0].toUpperCase()
        : 'O';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          // ── Owner avatar — initials (no hardcoded URL) ─────────────────
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primaryContainer,
                child: Text(
                  initial,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              if (land.isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 8,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // ── Owner info ────────────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.publicProfile, extra: ownerId),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'star',
                        color: const Color(0xFFF9A825),
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          land.ownerRating > 0
                              ? '${land.ownerRating.toStringAsFixed(1)} · ${t.landOwner}'
                              : t.landOwner,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: theme.colorScheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Contact actions ────────────────────────────────────────────
          GestureDetector(
            onTap: () => context.go(AppRoutes.chat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'chat_bubble_outline',
                    color: AppTheme.primary,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isContactRevealed ? t.message : t.chat,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
