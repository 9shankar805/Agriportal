import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../core/firestore_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_skeleton_widget.dart';
import './widgets/category_chip_widget.dart';
import './widgets/featured_banner_widget.dart';
import './widgets/land_listing_card_widget.dart';
import './widgets/listings_app_bar_widget.dart';
import './widgets/search_filter_widget.dart';

class LandModel {
  final String id;
  final String title;
  final String province;
  final String district;
  final String municipality;
  final double areaRopani;
  final String soilType;
  final String waterSource;
  final bool hasIrrigation;
  final double leasePriceMonthly;
  final String status;
  final String imageUrl;
  final String semanticLabel;
  final bool isVerified;
  final String category;
  final String ownerName;
  final double ownerRating;
  final double? latitude;
  final double? longitude;

  const LandModel({
    required this.id,
    required this.title,
    required this.province,
    required this.district,
    required this.municipality,
    required this.areaRopani,
    required this.soilType,
    required this.waterSource,
    required this.hasIrrigation,
    required this.leasePriceMonthly,
    required this.status,
    required this.imageUrl,
    required this.semanticLabel,
    required this.isVerified,
    required this.category,
    required this.ownerName,
    required this.ownerRating,
    this.latitude,
    this.longitude,
  });

  factory LandModel.fromMap(Map<String, dynamic> map) {
    return LandModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      province: map['province'] as String? ?? '',
      district: map['district'] as String? ?? '',
      municipality: map['municipality'] as String? ?? '',
      areaRopani: (map['area_ropani'] as num? ?? 0).toDouble(),
      soilType: map['soil_type'] as String? ?? '',
      waterSource: map['water_source'] as String? ?? '',
      hasIrrigation: map['has_irrigation'] as bool? ?? false,
      leasePriceMonthly: (map['lease_price_monthly'] as num? ?? 0).toDouble(),
      status: map['status'] as String? ?? 'approved',
      imageUrl: map['image_url'] as String? ?? '',
      semanticLabel: map['semantic_label'] as String? ?? '',
      isVerified: map['is_verified'] as bool? ?? false,
      category: map['category'] as String? ?? 'Other',
      ownerName: map['owner_name'] as String? ?? '',
      ownerRating: (map['owner_rating'] as num? ?? 0).toDouble(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  /// Build from a Firestore DocumentSnapshot — field names match Firestore schema
  factory LandModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return LandModel(
      id:                 doc.id,
      title:              d['title']              as String? ?? '',
      province:           d['province']           as String? ?? '',
      district:           d['district']           as String? ?? d['location'] as String? ?? '',
      municipality:       d['municipality']       as String? ?? '',
      areaRopani:         (d['areaBigha']         as num? ?? d['area'] as num? ?? 0).toDouble(),
      soilType:           d['soilType']           as String? ?? '',
      waterSource:        d['waterSource']        as String? ?? '',
      hasIrrigation:      d['hasIrrigation']      as bool? ?? false,
      leasePriceMonthly:  (d['pricePerBigha']     as num? ?? d['price'] as num? ?? 0).toDouble(),
      status:             d['status']             as String? ?? 'active',
      imageUrl:           d['imageUrl']           as String? ?? d['image_url'] as String? ?? '',
      semanticLabel:      d['title']              as String? ?? '',
      isVerified:         d['isVerified']         as bool? ?? false,
      category:           d['category']           as String? ?? 'Other',
      ownerName:          d['ownerName']          as String? ?? '',
      ownerRating:        (d['ownerRating']       as num? ?? 0).toDouble(),
      latitude:           (d['latitude']          as num?)?.toDouble(),
      longitude:          (d['longitude']         as num?)?.toDouble(),
    );
  }
}

class LandListingsScreen extends StatefulWidget {
  const LandListingsScreen({super.key});

  @override
  State<LandListingsScreen> createState() => _LandListingsScreenState();
}

class _LandListingsScreenState extends State<LandListingsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedProvince = 'All';

  final List<String> _categories = [
    'All',
    'Paddy',
    'Vegetable',
    'Orchard',
    'Pasture',
  ];
  final List<String> _provinces = [
    'All',
    'Bagmati',
    'Gandaki',
    'Lumbini',
    'Koshi',
  ];

  List<LandModel> _applyFiltersToList(List<LandModel> allLands) {
    List<LandModel> result = List.from(allLands);
    if (_selectedCategory != 'All') {
      result = result.where((l) => l.category == _selectedCategory).toList();
    }
    if (_selectedProvince != 'All') {
      result = result.where((l) => l.province == _selectedProvince).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (l) =>
                l.title.toLowerCase().contains(q) ||
                l.district.toLowerCase().contains(q) ||
                l.municipality.toLowerCase().contains(q),
          )
          .toList();
    }
    return result;
  }

  void _onSearch(String query) {
    setState(() => _searchQuery = query);
  }

  void _onCategorySelected(String cat) {
    setState(() => _selectedCategory = cat);
  }

  void _onLandTap(LandModel land) {
    context.push(AppRoutes.landDetail, extra: land.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirestoreService.instance.activeLandsStream(),
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            final allLands = snapshot.hasData
                ? snapshot.data!.docs
                    .map(LandModel.fromFirestore)
                    .where((l) => l.title.isNotEmpty)
                    .toList()
                : <LandModel>[];
            final filteredLands = _applyFiltersToList(allLands);

            return Column(
              children: [
                // ── Fixed app bar (not part of scroll view) ───────────────
                ListingsAppBarWidget(),
                // ── Scrollable content below ──────────────────────────────
                Expanded(
                  child: RefreshIndicator(
              onRefresh: () async {},
              color: theme.colorScheme.primary,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SearchFilterWidget(
                      onSearch: _onSearch,
                      selectedProvince: _selectedProvince,
                      provinces: _provinces,
                      onProvinceChanged: (p) =>
                          setState(() => _selectedProvince = p),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: CategoryChipWidget(
                      categories: _categories,
                      selected: _selectedCategory,
                      onSelected: _onCategorySelected,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: FeaturedBannerWidget(onExploreTap: () {}),
                    ),
                  ),
                  // Recommended section header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                      child: Text(
                        'Recommended Lands',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  // Horizontal recommended cards
                  SliverToBoxAdapter(
                    child: isLoading
                        ? SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(left: 16),
                              itemCount: 4,
                              itemBuilder: (_, __) =>
                                  const LandCardSkeletonWidget(),
                            ),
                          )
                        : SizedBox(
                            height: 228,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(left: 16),
                              itemCount: allLands.take(4).length,
                              itemBuilder: (context, index) {
                                final land = allLands[index];
                                return LandListingCardWidget(
                                  land: land,
                                  isHorizontal: true,
                                  onTap: () => _onLandTap(land),
                                );
                              },
                            ),
                          ),
                  ),
                  // All listings header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'All Listings',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '${filteredLands.length} lands available',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'sort',
                                  color: theme.colorScheme.onSurface,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Sort',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Listings
                  if (isLoading)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: LoadingSkeletonWidget(
                            width: double.infinity,
                            height: 100,
                            borderRadius: 16,
                          ),
                        ),
                        childCount: 5,
                      ),
                    )
                  else if (filteredLands.isEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 300,
                        child: EmptyStateWidget(
                          iconName: 'landscape',
                          title: 'No Lands Found',
                          subtitle:
                              'No agricultural land listings yet. Check back soon or adjust your filters.',
                        ),
                      ),
                    )
                  else if (isTablet)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => LandListingCardWidget(
                            land: filteredLands[index],
                            isHorizontal: false,
                            onTap: () => _onLandTap(filteredLands[index]),
                          ),
                          childCount: filteredLands.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.78,
                            ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final land = filteredLands[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: LandListingCardWidget(
                                land: land,
                                isHorizontal: false,
                                isListView: true,
                                onTap: () => _onLandTap(land),
                              ),
                            );
                          },
                          childCount: filteredLands.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          ],
        );
          },
        ),
      ),
    );
  }
}
