import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../core/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../land_listings_screen/land_listings_screen.dart';

class LandAmenitiesWidget extends StatelessWidget {
  final LandModel land;
  const LandAmenitiesWidget({required this.land, super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // 6 amenity items — 2-row × 3-col grid (locked from Image 2)
    final amenities = [
      _AmenityItem(
        icon: 'water',
        label: t.irrigation,
        available: land.hasIrrigation,
      ),
      _AmenityItem(
        icon: 'directions_car',
        label: t.roadAccess,
        available: true,
      ),
      _AmenityItem(
        icon: 'bolt',
        label: t.electricity,
        available: land.district != 'Mustang',
      ),
      _AmenityItem(
        icon: 'fence',
        label: t.fencing,
        available: land.areaRopani < 15,
      ),
      _AmenityItem(
        icon: 'warehouse',
        label: t.storage,
        available: land.areaRopani > 8,
      ),
      _AmenityItem(
        icon: 'science',
        label: t.soilTest,
        available: land.isVerified,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.landFeatures,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        // 2-row × 3-col grid (locked anatomy)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.4,
          ),
          itemCount: amenities.length,
          itemBuilder: (context, index) {
            final item = amenities[index];
            return Container(
              decoration: BoxDecoration(
                color: item.available
                    ? AppTheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: item.available
                      ? AppTheme.primary.withAlpha(77)
                      : theme.colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: item.icon,
                    color: item.available
                        ? AppTheme.primary
                        : theme.colorScheme.outline,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: item.available
                          ? AppTheme.primary
                          : theme.colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AmenityItem {
  final String icon;
  final String label;
  final bool available;
  const _AmenityItem({
    required this.icon,
    required this.label,
    required this.available,
  });
}
