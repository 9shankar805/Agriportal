import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../core/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';
import '../../land_listings_screen/land_listings_screen.dart';

class VirtualTourWidget extends StatelessWidget {
  final LandModel land;
  const VirtualTourWidget({required this.land, super.key});

  List<String> _getAllImages() {
    final images = <String>[];
    if (land.imageUrl.isNotEmpty) {
      images.add(land.imageUrl);
    }
    for (final url in land.imageUrls) {
      if (!images.contains(url)) {
        images.add(url);
      }
    }
    if (images.isEmpty) {
      return [
        'https://images.pexels.com/photos/974314/pexels-photo-974314.jpeg',
        'https://images.pexels.com/photos/2518861/pexels-photo-2518861.jpeg',
        'https://images.pexels.com/photos/1581484/pexels-photo-1581484.jpeg',
      ];
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final galleryImages = _getAllImages();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.landGallery,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    t.exploreEveryCorner,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'photo_library',
                    color: AppTheme.primary,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: galleryImages.length,
            itemBuilder: (context, index) {
              return Container(
                width: 90,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImageWidget(
                    imageUrl: galleryImages[index],
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    semanticLabel: 'Land image ${index + 1}',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
