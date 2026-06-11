import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/user_session.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_image_widget.dart';
import '../../widgets/empty_state_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

class SavedLand {
  final String id;
  final String title;
  final String district;
  final String province;
  final double areaRopani;
  final double leasePriceMonthly;
  final String imageUrl;
  final String category;
  final bool isVerified;
  final double ownerRating;
  final String savedDate;

  const SavedLand({
    required this.id,
    required this.title,
    required this.district,
    required this.province,
    required this.areaRopani,
    required this.leasePriceMonthly,
    required this.imageUrl,
    required this.category,
    required this.isVerified,
    required this.ownerRating,
    required this.savedDate,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class SavedLandsScreen extends StatefulWidget {
  const SavedLandsScreen({super.key});

  @override
  State<SavedLandsScreen> createState() => _SavedLandsScreenState();
}

class _SavedLandsScreenState extends State<SavedLandsScreen> {
  List<SavedLand> _savedLands = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFromFirestore();
  }

  Future<void> _loadFromFirestore() async {
    final uid = UserSession.instance.uid;
    if (uid.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('savedLands')
          .get();
      if (mounted) {
        // Sort client-side (no composite index needed)
        final docs = List.of(snap.docs)
          ..sort((a, b) {
            final aTs = (a.data())['savedAt'] as Timestamp?;
            final bTs = (b.data())['savedAt'] as Timestamp?;
            if (aTs == null && bTs == null) return 0;
            if (aTs == null) return 1;
            if (bTs == null) return -1;
            return bTs.compareTo(aTs);
          });
        setState(() {
          _savedLands = docs.map((d) {
            final v = d.data();
            return SavedLand(
              id:               d.id,
              title:            v['title']             as String? ?? '',
              district:         v['district']          as String? ?? '',
              province:         v['province']          as String? ?? '',
              areaRopani:       (v['areaRopani']        as num? ?? 0).toDouble(),
              leasePriceMonthly:(v['leasePriceMonthly'] as num? ?? 0).toDouble(),
              imageUrl:         v['imageUrl']           as String? ?? '',
              category:         v['category']           as String? ?? '',
              isVerified:       v['isVerified']         as bool? ?? false,
              ownerRating:      (v['ownerRating']       as num? ?? 0).toDouble(),
              savedDate:        v['savedAt'] is Timestamp
                  ? _fmtDate((v['savedAt'] as Timestamp).toDate())
                  : '',
            );
          }).toList();
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  String _fmtDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month]} ${d.day}, ${d.year}';
  }

  Future<void> _removeSaved(String id) async {
    setState(() => _savedLands.removeWhere((l) => l.id == id));
    final uid = UserSession.instance.uid;
    if (uid.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('savedLands')
          .doc(id)
          .delete()
          .catchError((_) {});
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Removed from saved lands',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 22,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Saved Lands',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          if (_savedLands.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_savedLands.length} saved',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _savedLands.isEmpty
              ? EmptyStateWidget(
                  iconName: 'favorite_border',
                  title: 'No Saved Lands',
                  subtitle:
                      'Tap the heart icon on any listing to save lands you are interested in.',
                  ctaLabel: 'Browse Lands',
                  onCtaTap: () => context.go(AppRoutes.landListings),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: _savedLands.length,
                  itemBuilder: (context, index) {
                    final land = _savedLands[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SavedLandCard(
                        land: land,
                        onRemove: () => _removeSaved(land.id),
                        onTap: () => context.push(
                            AppRoutes.landDetail,
                            extra: land.id),
                      ),
                    );
                  },
                ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card
// ─────────────────────────────────────────────────────────────────────────────

class _SavedLandCard extends StatelessWidget {
  final SavedLand land;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _SavedLandCard({
    required this.land,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft:    Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: CustomImageWidget(
                imageUrl: land.imageUrl,
                width:  110,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),

            // ── Content ────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category + verified + remove
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            land.category,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        if (land.isVerified) ...[
                          const SizedBox(width: 4),
                          CustomIconWidget(
                            iconName: 'verified',
                            color: theme.colorScheme.primary,
                            size: 14,
                          ),
                        ],
                        const Spacer(),
                        GestureDetector(
                          onTap: onRemove,
                          child: const CustomIconWidget(
                            iconName: 'favorite',
                            color: Color(0xFFE53935),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      land.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Location
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'location_on',
                          color: theme.colorScheme.outline,
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${land.district}, ${land.province}',
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
                    const SizedBox(height: 6),

                    // Price + area
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'NPR ${land.leasePriceMonthly.toInt()}/mo',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${land.areaRopani} Ro.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: theme.colorScheme.outline,
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
