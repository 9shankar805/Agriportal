import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../core/app_localizations.dart';
import '../../../core/firestore_service.dart';
import '../../../models/nepal_location_model.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';
import '../land_listings_screen.dart';

class LandListingCardWidget extends StatefulWidget {
  final LandModel land;
  final bool isHorizontal;
  final bool isListView;
  final VoidCallback onTap;
  final NepalLocationResponse? nepalLocationData;

  const LandListingCardWidget({
    required this.land,
    required this.isHorizontal,
    this.isListView = false,
    required this.onTap,
    this.nepalLocationData,
    super.key,
  });

  @override
  State<LandListingCardWidget> createState() => _LandListingCardWidgetState();
}

class _LandListingCardWidgetState extends State<LandListingCardWidget> {
  bool _isSaved = false;
  bool _isLoading = false;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _checkInitialSaveState();
    LanguageController.instance.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageController.instance.removeListener(_onLanguageChanged);
    _pageController.dispose();
    super.dispose();
  }

  List<String> _getAllImages() {
    final images = <String>[];
    if (widget.land.imageUrl.isNotEmpty) {
      images.add(widget.land.imageUrl);
    }
    for (final url in widget.land.imageUrls) {
      if (!images.contains(url)) {
        images.add(url);
      }
    }
    return images.isNotEmpty ? images : ['https://images.pexels.com/photos/974314/pexels-photo-974314.jpeg'];
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  String _getTranslatedLocationName(String nameEn) {
    if (widget.nepalLocationData == null) return nameEn;
    
    for (final province in widget.nepalLocationData!.provinceList) {
      if (province.nameEn == nameEn) {
        if (LanguageController.instance.isNepali && province.nameNp != null) {
          return province.nameNp!;
        }
        return province.nameEn;
      }
      
      for (final district in province.districtList) {
        if (district.nameEn == nameEn) {
          if (LanguageController.instance.isNepali && district.nameNp != null) {
            return district.nameNp!;
          }
          return district.nameEn;
        }
        
        for (final municipality in district.municipalityList) {
          if (municipality.nameEn == nameEn) {
            if (LanguageController.instance.isNepali && municipality.nameNp != null) {
              return municipality.nameNp!;
            }
            return municipality.nameEn;
          }
        }
      }
    }
    
    return nameEn;
  }

  Future<void> _checkInitialSaveState() async {
    try {
      final isSaved = await FirestoreService.instance.isLandSaved(widget.land.id);
      if (mounted) {
        setState(() => _isSaved = isSaved);
      }
    } catch (_) {}
  }

  Future<void> _toggleSave() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      if (_isSaved) {
        await FirestoreService.instance.unsaveLand(widget.land.id);
      } else {
        // Convert LandModel to Map for saving
        final landData = {
          'title': widget.land.title,
          'province': widget.land.province,
          'district': widget.land.district,
          'municipality': widget.land.municipality,
          'areaRopani': widget.land.areaRopani,
          'soilType': widget.land.soilType,
          'waterSource': widget.land.waterSource,
          'hasIrrigation': widget.land.hasIrrigation,
          'leasePriceMonthly': widget.land.leasePriceMonthly,
          'status': widget.land.status,
          'imageUrl': widget.land.imageUrl,
          'semanticLabel': widget.land.semanticLabel,
          'isVerified': widget.land.isVerified,
          'category': widget.land.category,
          'ownerName': widget.land.ownerName,
          'ownerRating': widget.land.ownerRating,
          'latitude': widget.land.latitude,
          'longitude': widget.land.longitude,
          'description': widget.land.description,
          'imageUrls': widget.land.imageUrls,
          'landFeatures': widget.land.landFeatures,
          'suggestedCrops': widget.land.suggestedCrops,
        };
        await FirestoreService.instance.saveLand(widget.land.id, landData);
      }
      if (mounted) {
        setState(() => _isSaved = !_isSaved);
      }
    } catch (e) {
      // Show error snackbar
      if (mounted) {
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.failedToUpdateSavedLands)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isListView) return _buildListCard(context);
    return _buildGridCard(context);
  }

  // ── Grid / Horizontal card ────────────────────────────────────────────────

  Widget _buildGridCard(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);
    final images = _getAllImages();
    return Container(
      width: widget.isHorizontal ? 195 : null,
      margin: widget.isHorizontal ? const EdgeInsets.only(right: 12) : null,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppTheme.primary.withAlpha(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ───────────────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    width: double.infinity,
                    height: widget.isHorizontal ? 115 : 140,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (index) => setState(() => _currentImageIndex = index),
                      itemBuilder: (context, index) {
                        return CustomImageWidget(
                          imageUrl: images[index],
                          width: double.infinity,
                          height: widget.isHorizontal ? 115 : 140,
                          fit: BoxFit.cover,
                          semanticLabel: widget.land.semanticLabel,
                        );
                      },
                    ),
                  ),
                ),
                if (images.length > 1)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (index) {
                        return Container(
                          width: _currentImageIndex == index ? 16 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: _currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withAlpha(128),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                  ),
                if (widget.land.isVerified)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'verified',
                            color: Colors.white,
                            size: 9,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            t.verified,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _isLoading ? null : _toggleSave,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(230),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                ),
                              )
                            : CustomIconWidget(
                                iconName:
                                    _isSaved ? 'favorite' : 'favorite_border',
                                color: _isSaved
                                    ? const Color(0xFFE53935)
                                    : Colors.grey,
                                size: 14,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // ── Info ─────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.land.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: theme.colorScheme.outline,
                        size: 11,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${_getTranslatedLocationName(widget.land.municipality)}, ${_getTranslatedLocationName(widget.land.district)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: theme.colorScheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'NPR ${widget.land.leasePriceMonthly.toStringAsFixed(0)}${t.perMonthSuffix}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.land.areaRopani} Ro.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── List card ─────────────────────────────────────────────────────────────

  Widget _buildListCard(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppTheme.primary.withAlpha(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ───────────────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                  child: CustomImageWidget(
                    imageUrl: widget.land.imageUrl,
                    width: 105,
                    height: 118,
                    fit: BoxFit.cover,
                    semanticLabel: widget.land.semanticLabel,
                  ),
                ),
                if (widget.land.isVerified)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: CustomIconWidget(
                        iconName: 'verified',
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
            // ── Info ─────────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title + heart
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.land.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: _isLoading ? null : _toggleSave,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 17,
                                    height: 17,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                    ),
                                  )
                                : CustomIconWidget(
                                    iconName: _isSaved
                                        ? 'favorite'
                                        : 'favorite_border',
                                    color: _isSaved
                                        ? const Color(0xFFE53935)
                                        : theme.colorScheme.outline,
                                    size: 17,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Location
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'location_on',
                          color: theme.colorScheme.outline,
                          size: 11,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '${_getTranslatedLocationName(widget.land.municipality)}, ${_getTranslatedLocationName(widget.land.district)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: theme.colorScheme.outline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Area + water — wrap to prevent overflow
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children: [
                        _MetaChip(
                          icon: 'straighten',
                          label: '${widget.land.areaRopani} Ro.',
                          color: theme.colorScheme.outline,
                        ),
                        _MetaChip(
                          icon: 'water_drop',
                          label: widget.land.waterSource,
                          color: AppTheme.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    // Price + category — both constrained
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'NPR ${widget.land.leasePriceMonthly.toStringAsFixed(0)}${t.perMonthSuffix}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.land.category,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small meta chip used inside list card
// ─────────────────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(iconName: icon, color: color, size: 11),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: color,
          ),
        ),
      ],
    );
  }
}
