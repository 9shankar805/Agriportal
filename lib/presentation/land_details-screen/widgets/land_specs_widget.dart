import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../core/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../land_listings_screen/land_listings_screen.dart';

class LandSpecsWidget extends StatelessWidget {
  final LandModel land;
  const LandSpecsWidget({required this.land, super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final specs = [
      _SpecItem(
        icon: 'straighten',
        label: '${land.areaRopani} Ropani',
        subtitle: t.totalArea,
      ),
      _SpecItem(icon: 'terrain', label: land.soilType, subtitle: t.soilType),
      _SpecItem(
        icon: 'water_drop',
        label: land.waterSource,
        subtitle: t.waterSource,
      ),
      _SpecItem(
        icon: 'calendar_today',
        label: t.flexible,
        subtitle: t.leaseTerm,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: specs.map((spec) {
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: spec.icon,
                      color: AppTheme.primary,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      spec.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      spec.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SpecItem {
  final String icon;
  final String label;
  final String subtitle;
  const _SpecItem({
    required this.icon,
    required this.label,
    required this.subtitle,
  });
}
