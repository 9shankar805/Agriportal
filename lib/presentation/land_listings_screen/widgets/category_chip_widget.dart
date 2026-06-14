import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../core/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class CategoryChipWidget extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryChipWidget({
    required this.categories,
    required this.selected,
    required this.onSelected,
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
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selected;

          return GestureDetector(
            onTap: () => onSelected(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primary
                      : theme.colorScheme.outlineVariant,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withAlpha(55),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: _iconForCategory(cat),
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getTranslatedCategory(cat, t),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
