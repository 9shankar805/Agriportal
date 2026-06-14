// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../../../core/app_export.dart';
// import '../../../core/app_localizations.dart';
// import '../../../theme/app_theme.dart';
// import '../../../widgets/custom_icon_widget.dart';

// class CategoryChipWidget extends StatelessWidget {
//   final List<String> categories;
//   final String selected;
//   final ValueChanged<String> onSelected;

//   const CategoryChipWidget({
//     required this.categories,
//     required this.selected,
//     required this.onSelected,
//     super.key,
//   });

//   String _iconForCategory(String cat) {
//     switch (cat) {
//       case 'Paddy':
//         return 'grass';
//       case 'Vegetable':
//         return 'eco';
//       case 'Orchard':
//         return 'park';
//       case 'Pasture':
//         return 'terrain';
//       default:
//         return 'apps';
//     }
//   }

//   String _getTranslatedCategory(String cat, AppLocalizations t) {
//     switch (cat) {
//       case 'All':
//         return t.allCategories;
//       case 'Paddy':
//         return t.paddy;
//       case 'Vegetable':
//         return t.vegetable;
//       case 'Orchard':
//         return t.orchard;
//       case 'Pasture':
//         return t.pasture;
//       default:
//         return cat;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final t = AppLocalizations.of(context);
//     return SizedBox(
//       height: 104,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
//         itemCount: categories.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 10),
//         itemBuilder: (context, index) {
//           final cat = categories[index];
//           final isSelected = cat == selected;
//           return InkWell(
//             onTap: () => onSelected(cat),
//             borderRadius: BorderRadius.circular(18),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 220),
//               curve: Curves.easeOutCubic,
//               width: 78,
//               decoration: BoxDecoration(
//                 color: isSelected
//                     ? AppTheme.primary.withOpacity(0.08)
//                     : theme.colorScheme.surface,
//                 borderRadius: BorderRadius.circular(18),
//                 border: Border.all(
//                   color: isSelected
//                       ? AppTheme.primary
//                       : theme.colorScheme.outlineVariant,
//                   width: isSelected ? 1.4 : 1,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.06),
//                     blurRadius: 10,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? AppTheme.primary
//                           : theme.colorScheme.surfaceContainerHighest,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: isSelected
//                           ? [
//                               BoxShadow(
//                                 color: AppTheme.primary.withOpacity(0.22),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 3),
//                               ),
//                             ]
//                           : null,
//                     ),
//                     child: Center(
//                       child: CustomIconWidget(
//                         iconName: _iconForCategory(cat),
//                         color: isSelected
//                             ? Colors.white
//                             : theme.colorScheme.onSurfaceVariant,
//                         size: 19,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     _getTranslatedCategory(cat, t),
//                     style: GoogleFonts.plusJakartaSans(
//                       fontSize: 10.5,
//                       fontWeight: isSelected
//                           ? FontWeight.w700
//                           : FontWeight.w500,
//                       color: isSelected
//                           ? AppTheme.primary
//                           : theme.colorScheme.onSurface,
//                     ),
//                     textAlign: TextAlign.center,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../core/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class CategoryChipWidget extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  /// Optional item count per category, e.g. {'Paddy': 12, 'Orchard': 15}.
  /// Categories missing from this map render without a count badge, so
  /// it's safe to omit entirely while counts aren't wired up yet.
  final Map<String, int> counts;

  const CategoryChipWidget({
    required this.categories,
    required this.selected,
    required this.onSelected,
    this.counts = const {},
    super.key,
  });

  String _iconForCategory(String cat) {
    switch (cat) {
      case 'Paddy':     return 'grass';
      case 'Vegetable': return 'eco';
      case 'Orchard':   return 'park';
      case 'Pasture':   return 'terrain';
      default:          return 'apps';
    }
  }

  String _getTranslatedCategory(String cat, AppLocalizations t) {
    switch (cat) {
      case 'All':       return t.allCategories;
      case 'Paddy':     return t.paddy;
      case 'Vegetable': return t.vegetable;
      case 'Orchard':   return t.orchard;
      case 'Pasture':   return t.pasture;
      default:          return cat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selected;
          final count = counts[cat];
          final style = _PillStyle.resolve(theme, isSelected);
          final label = _getTranslatedCategory(cat, t);

          return Semantics(
            selected: isSelected,
            button: true,
            label: count != null ? '$label, $count' : label,
            child: InkWell(
              key: ValueKey('category_chip_$cat'),
              onTap: () {
                HapticFeedback.selectionClick();
                onSelected(cat);
              },
              borderRadius: BorderRadius.circular(_pillRadius),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsetsDirectional.fromSTEB(12, 7, 10, 7),
                decoration: BoxDecoration(
                  color: style.background,
                  borderRadius: BorderRadius.circular(_pillRadius),
                  border: Border.all(
                    color: style.border,
                    width: isSelected ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: _iconForCategory(cat),
                      color: style.icon,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.w400,
                        color: style.label,
                      ),
                    ),
                    if (count != null) ...[
                      const SizedBox(width: 6),
                      _CountBadge(count: count, style: style),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

const double _pillRadius = 999;

/// Resolved colors for a pill in its selected/unselected state.
/// Centralizing this avoids branching on `isSelected` in four separate
/// places throughout the build method.
class _PillStyle {
  final Color background;
  final Color border;
  final Color icon;
  final Color label;
  final Color badgeBackground;
  final Color badgeText;

  const _PillStyle({
    required this.background,
    required this.border,
    required this.icon,
    required this.label,
    required this.badgeBackground,
    required this.badgeText,
  });

  factory _PillStyle.resolve(ThemeData theme, bool isSelected) {
    if (isSelected) {
      return _PillStyle(
        background: AppTheme.primary.withOpacity(0.08),
        border: AppTheme.primary,
        icon: AppTheme.primary,
        label: AppTheme.primary,
        badgeBackground: AppTheme.primary,
        badgeText: Colors.white,
      );
    }
    return _PillStyle(
      background: theme.colorScheme.surface,
      border: theme.colorScheme.outlineVariant,
      icon: theme.colorScheme.onSurfaceVariant,
      label: theme.colorScheme.onSurface,
      badgeBackground: theme.colorScheme.surfaceContainerHighest,
      badgeText: theme.colorScheme.onSurfaceVariant,
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final _PillStyle style;

  const _CountBadge({required this.count, required this.style});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      constraints: const BoxConstraints(minWidth: 18),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: style.badgeBackground,
        borderRadius: BorderRadius.circular(_pillRadius),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: style.badgeText,
        ),
      ),
    );
  }
}
