import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/user_session.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_icon_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tab spec
// ─────────────────────────────────────────────────────────────────────────────

class _TabSpec {
  final String label;
  final String activeIcon;
  final String inactiveIcon;
  final int branchIndex;
  final int? badgeCount;

  const _TabSpec({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.branchIndex,
    this.badgeCount,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Farmer tabs
// Branch 0: Explore · Branch 2: Applications · Branch 3: Chat · Branch 4: Profile
// ─────────────────────────────────────────────────────────────────────────────

const List<_TabSpec> _farmerTabs = [
  _TabSpec(
    label: 'Explore',
    activeIcon: 'explore',
    inactiveIcon: 'explore_outlined',
    branchIndex: 0,
  ),
  _TabSpec(
    label: 'Applications',
    activeIcon: 'assignment',
    inactiveIcon: 'assignment_outlined',
    branchIndex: 2,
  ),
  _TabSpec(
    label: 'Messages',
    activeIcon: 'chat_bubble',
    inactiveIcon: 'chat_bubble_outline',
    branchIndex: 3,
    badgeCount: 3,
  ),
  _TabSpec(
    label: 'Profile',
    activeIcon: 'person',
    inactiveIcon: 'person_outline',
    branchIndex: 4,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Land Owner tabs
// Branch 1: My Lands · Branch 2: Applications · Branch 3: Chat · Branch 4: Profile
// ─────────────────────────────────────────────────────────────────────────────

const List<_TabSpec> _ownerTabs = [
  _TabSpec(
    label: 'My Lands',
    activeIcon: 'landscape',
    inactiveIcon: 'landscape_outlined',
    branchIndex: 1,
  ),
  _TabSpec(
    label: 'Applications',
    activeIcon: 'assignment',
    inactiveIcon: 'assignment_outlined',
    branchIndex: 2,
  ),
  _TabSpec(
    label: 'Messages',
    activeIcon: 'chat_bubble',
    inactiveIcon: 'chat_bubble_outline',
    branchIndex: 3,
    badgeCount: 3,
  ),
  _TabSpec(
    label: 'Profile',
    activeIcon: 'person',
    inactiveIcon: 'person_outline',
    branchIndex: 4,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────────────────────────

class AppNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppNavigation({required this.navigationShell, super.key});

  List<_TabSpec> get _tabs =>
      UserSession.instance.isLandOwner ? _ownerTabs : _farmerTabs;

  /// Maps the shell's current branch index → visual tab index
  int get _selectedVisualIndex {
    final currentBranch = navigationShell.currentIndex;
    final idx = _tabs.indexWhere((t) => t.branchIndex == currentBranch);
    return idx < 0 ? 0 : idx;
  }

  void _onTabTap(int visualIndex) {
    final tab = _tabs[visualIndex];
    navigationShell.goBranch(
      tab.branchIndex,
      initialLocation: tab.branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOwner = UserSession.instance.isLandOwner;
    final tabs = _tabs;

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
              return Expanded(
                child: _NavItem(
                  tab: tab,
                  isSelected: isSelected,
                  isOwner: isOwner,
                  onTap: () => _onTabTap(i),
                ),
              );
            }),
          ),
        ),
      ),
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
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.isOwner,
    required this.onTap,
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
            // Icon pill with optional badge
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
                // Notification badge
                if (tab.badgeCount != null && tab.badgeCount! > 0 && !isSelected)
                  Positioned(
                    right: 8,
                    top: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${tab.badgeCount}',
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
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
  }
}
