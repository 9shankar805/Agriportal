import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_export.dart';
import '../../../core/app_localizations.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';
import '../../../core/user_session.dart';

class ListingsAppBarWidget extends StatelessWidget {
  const ListingsAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final t = AppLocalizations.of(context);
    // On narrow screens hide the location chip text, keep icon only
    final isNarrow = screenWidth < 360;

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Logo ──────────────────────────────────────────────────────────
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'eco',
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Agri',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                TextSpan(
                  text: 'Portal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // ── Location chip ─────────────────────────────────────────────────
          if (!isNarrow)
            Container(
              constraints: const BoxConstraints(maxWidth: 100),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'location_on',
                    color: AppTheme.primary,
                    size: 13,
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      t.nepal,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: theme.colorScheme.outline,
                    size: 13,
                  ),
                ],
              ),
            ),

          if (!isNarrow) const SizedBox(width: 6),

          // ── Saved lands ───────────────────────────────────────────────────
          _AppBarIconButton(
            icon: 'favorite_border',
            onTap: () => context.push(AppRoutes.savedLands),
            theme: theme,
          ),
          const SizedBox(width: 6),

          // ── Notifications ─────────────────────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              _AppBarIconButton(
                icon: 'notifications_outlined',
                onTap: () => context.push(AppRoutes.notifications),
                theme: theme,
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC62828),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),

          // ── Avatar → Profile ──────────────────────────────────────────────
          GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: _UserAvatar(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small icon button
// ─────────────────────────────────────────────────────────────────────────────

class _AppBarIconButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  final ThemeData theme;

  const _AppBarIconButton({
    required this.icon,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: theme.colorScheme.onSurface,
            size: 19,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// User avatar — shows Firebase photo or initials
// ─────────────────────────────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final photoUrl = UserSession.instance.firebaseUser?.photoURL ?? '';
    final name = UserSession.instance.displayName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    if (photoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: CustomImageWidget(
          imageUrl: photoUrl,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          semanticLabel: 'Profile photo',
        ),
      );
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: AppTheme.primaryContainer,
      child: Text(
        initial,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}
