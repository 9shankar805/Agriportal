import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/user_session.dart';
import '../core/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_icon_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tab spec
// ─────────────────────────────────────────────────────────────────────────────

class _TabSpec {
  final String labelKey;
  final String activeIcon;
  final String inactiveIcon;
  final int branchIndex;
  final bool showUnreadBadge;

  const _TabSpec({
    required this.labelKey,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.branchIndex,
    this.showUnreadBadge = false,
  });

  String getLabel(AppLocalizations t) {
    switch (labelKey) {
      case 'explore':
        return t.explore;
      case 'myLands':
        return t.myLands;
      case 'applications':
        return t.applications;
      case 'messages':
        return t.messages;
      case 'profile':
        return t.profile;
      default:
        return '';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Farmer tabs
// Branch 0: Explore · Branch 2: Applications · Branch 3: Chat · Branch 4: Profile
// ─────────────────────────────────────────────────────────────────────────────

List<_TabSpec> get _farmerTabs => [
  const _TabSpec(
    activeIcon: 'explore',
    inactiveIcon: 'explore_outlined',
    branchIndex: 0,
    labelKey: 'explore',
  ),
  const _TabSpec(
    activeIcon: 'assignment',
    inactiveIcon: 'assignment_outlined',
    branchIndex: 2,
    labelKey: 'applications',
  ),
  const _TabSpec(
    activeIcon: 'chat_bubble',
    inactiveIcon: 'chat_bubble_outlined',
    branchIndex: 3,
    showUnreadBadge: true,
    labelKey: 'messages',
  ),
  const _TabSpec(
    activeIcon: 'person',
    inactiveIcon: 'person_outlined',
    branchIndex: 4,
    labelKey: 'profile',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Land Owner tabs
// Branch 1: My Lands · Branch 2: Applications · Branch 3: Chat · Branch 4: Profile
// ─────────────────────────────────────────────────────────────────────────────

List<_TabSpec> get _ownerTabs => [
  const _TabSpec(
    labelKey: 'myLands',
    activeIcon: 'landscape',
    inactiveIcon: 'landscape_outlined',
    branchIndex: 1,
  ),
  const _TabSpec(
    labelKey: 'applications',
    activeIcon: 'assignment',
    inactiveIcon: 'assignment_outlined',
    branchIndex: 2,
  ),
  const _TabSpec(
    labelKey: 'messages',
    activeIcon: 'chat_bubble',
    inactiveIcon: 'chat_bubble_outlined',
    branchIndex: 3,
    showUnreadBadge: true,
  ),
  const _TabSpec(
    labelKey: 'profile',
    activeIcon: 'person',
    inactiveIcon: 'person_outlined',
    branchIndex: 4,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Unread count helper — reads total unread from Firebase RTDB
// ─────────────────────────────────────────────────────────────────────────────

Stream<int> _totalUnreadStream() {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(0);

  return FirebaseDatabase.instance
      .ref('conversations')
      .onValue
      .map((event) {
    final snap = event.snapshot;
    if (!snap.exists || snap.value == null) return 0;
    final map = Map<String, dynamic>.from(snap.value as Map);
    int total = 0;
    for (final entry in map.values) {
      if (entry is! Map) continue;
      final data = Map<String, dynamic>.from(entry);
      final aId = data['participantAId'] as String? ?? '';
      final bId = data['participantBId'] as String? ?? '';
      if (aId == uid) {
        total += (data['unreadCountA'] as int? ?? 0);
      } else if (bId == uid) {
        total += (data['unreadCountB'] as int? ?? 0);
      }
    }
    return total;
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────────────────────────

class AppNavigation extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppNavigation({required this.navigationShell, super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  @override
  void initState() {
    super.initState();
    LanguageController.instance.addListener(_onLanguageChange);
  }

  @override
  void dispose() {
    LanguageController.instance.removeListener(_onLanguageChange);
    super.dispose();
  }

  void _onLanguageChange() {
    setState(() {});
  }

  List<_TabSpec> get _tabs =>
      UserSession.instance.isLandOwner ? _ownerTabs : _farmerTabs;

  /// Maps the shell's current branch index → visual tab index
  int get _selectedVisualIndex {
    final currentBranch = widget.navigationShell.currentIndex;
    final idx = _tabs.indexWhere((t) => t.branchIndex == currentBranch);
    return idx < 0 ? 0 : idx;
  }

  void _onTabTap(int visualIndex) {
    final tab = _tabs[visualIndex];
    widget.navigationShell.goBranch(
      tab.branchIndex,
      initialLocation: tab.branchIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOwner = UserSession.instance.isLandOwner;
    final tabs = _tabs;
    final t = AppLocalizations.of(context);

    return StreamBuilder<int>(
      stream: _totalUnreadStream(),
      initialData: 0,
      builder: (context, unreadSnap) {
        final totalUnread = unreadSnap.data ?? 0;

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 0.8,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final tab = tabs[i];
                  final isSelected = i == _selectedVisualIndex;
                  final badgeCount =
                      tab.showUnreadBadge ? totalUnread : 0;
                  return Expanded(
                    child: _NavItem(
                      tab: tab,
                      isSelected: isSelected,
                      isOwner: isOwner,
                      badgeCount: badgeCount,
                      onTap: () => _onTabTap(i),
                      t: t,
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single nav item
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final _TabSpec tab;
  final bool isSelected;
  final bool isOwner;
  final int badgeCount;
  final VoidCallback onTap;
  final AppLocalizations t;

  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.isOwner,
    required this.badgeCount,
    required this.onTap,
    required this.t,
  });

  Color _activeColor(BuildContext context) {
    if (isOwner) return AppTheme.primary;
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = _activeColor(context);
    final inactiveColor = theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon pill with optional live badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withAlpha(30)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: CustomIconWidget(
                    iconName: isSelected ? tab.activeIcon : tab.inactiveIcon,
                    color: isSelected ? activeColor : inactiveColor,
                    size: 22,
                  ),
                ),
                // Live unread badge — only when not selected and count > 0
                if (badgeCount > 0 && !isSelected)
                  Positioned(
                    right: 8,
                    top: 0,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? activeColor : inactiveColor,
              ),
              child: Text(tab.getLabel(t)),
            ),
          ],
        ),
      ),
    );
  }
}
