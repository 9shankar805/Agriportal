import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../core/app_localizations.dart';
import '../../../core/firestore_service.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_image_widget.dart';
import '../../land_listings_screen/land_listings_screen.dart';

class SimilarLandsWidget extends StatefulWidget {
  final String currentLandId;

  const SimilarLandsWidget({
    required this.currentLandId,
    super.key,
    // Kept for backwards-compat — ignored; data comes from Firestore now
    List<LandModel>? allLands,
  });

  @override
  State<SimilarLandsWidget> createState() => _SimilarLandsWidgetState();
}

class _SimilarLandsWidgetState extends State<SimilarLandsWidget> {
  @override
  void initState() {
    super.initState();
    LanguageController.instance.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageController.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.instance.activeLandsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final similar = snapshot.data!.docs
            .map(LandModel.fromFirestore)
            .where((l) => l.id != widget.currentLandId && l.title.isNotEmpty)
            .take(4)
            .toList();

        if (similar.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.similarLands,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.landListings),
                    child: Text(
                      t.seeAll,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: similar.length,
                itemBuilder: (context, index) {
                  final land = similar[index];
                  return GestureDetector(
                    onTap: () =>
                        context.push(AppRoutes.landDetail, extra: land.id),
                    child: Container(
                      width: 130,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: CustomImageWidget(
                              imageUrl: land.imageUrl,
                              width: 130,
                              height: 140,
                              fit: BoxFit.cover,
                              semanticLabel: land.semanticLabel,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0xCC000000),
                                ],
                                stops: [0.4, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 8,
                            right: 8,
                            child: Text(
                              'NPR ${land.leasePriceMonthly.toStringAsFixed(0)}${t.perMonthSuffix}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
