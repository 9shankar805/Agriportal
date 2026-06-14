import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_export.dart';
import '../../../core/app_localizations.dart';
import '../../../core/user_session.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';

class ListingsAppBarWidget extends StatelessWidget {
  const ListingsAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          // ── Brand ────────────────────────────────────────────────────────
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: CustomIconWidget(
                iconName: 'eco',
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomIconWidget(
                  iconName: 'location_on',
                  color: AppTheme.primary,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  t.nepal,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Saved ─────────────────────────────────────────────────────────
          _IconBtn(
            icon: 'favorite_border',
            onTap: () => context.push(AppRoutes.savedLands),
          ),
          const SizedBox(width: 6),

          // ── Notifications ─────────────────────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              _IconBtn(
                icon: 'notifications_outlined',
                onTap: () => context.push(AppRoutes.notifications),
              ),
              Positioned(
                top: 3,
                right: 3,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppTheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),

          // ── Avatar ─────────────────────────────────────────────────────────
          GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: _UserAvatar(),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            size: 18,
          ),
        ),
      ),
    );
  }
}

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
