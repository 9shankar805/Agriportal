import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../core/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';

class CustomizeOptionsWidget extends StatelessWidget {
  final String category;
  const CustomizeOptionsWidget({required this.category, super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Crop planning options — locked from Image 1: 4 circle image + label below, horizontal scroll
    final options = [
      _CropOption(
        imageUrl:
            'https://images.pexels.com/photos/974314/pexels-photo-974314.jpeg',
        semanticLabel: 'Rice paddy crop growing in flooded field',
        label: t.rice,
      ),
      _CropOption(
        imageUrl:
            'https://images.pixabay.com/photo/2016/08/11/08/04/vegetables-1585060_1280.jpg',
        semanticLabel: 'Wheat crop growing in open field under blue sky',
        label: t.wheat,
      ),
      _CropOption(
        imageUrl:
            'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=300',
        semanticLabel: 'Vegetable crops growing in organized rows in garden',
        label: t.vegetables,
      ),
      _CropOption(
        imageUrl:
            'https://images.pexels.com/photos/1581484/pexels-photo-1581484.jpeg',
        semanticLabel: 'Tea leaves growing on hillside plantation',
        label: t.tea,
      ),
    ];

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
                    t.suggestedCrops,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    t.bestSuitedForSoil,
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
                    iconName: 'arrow_forward',
                    color: AppTheme.primary,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Horizontal scroll — circle image + label (locked from Image 1 customize section)
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final opt = options[index];
              return Container(
                width: 72,
                margin: const EdgeInsets.only(right: 14),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primary.withAlpha(77),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: CustomImageWidget(
                          imageUrl: opt.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          semanticLabel: opt.semanticLabel,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      opt.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CropOption {
  final String imageUrl;
  final String semanticLabel;
  final String label;
  const _CropOption({
    required this.imageUrl,
    required this.semanticLabel,
    required this.label,
  });
}
