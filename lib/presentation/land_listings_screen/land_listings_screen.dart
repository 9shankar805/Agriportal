import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../core/app_localizations.dart';
import '../../core/firestore_service.dart';
import '../../models/nepal_location_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_skeleton_widget.dart';
import './widgets/category_chip_widget.dart';
import './widgets/featured_banner_widget.dart';
import './widgets/land_listing_card_widget.dart';
import './widgets/listings_app_bar_widget.dart';
import './widgets/search_filter_widget.dart';

class LandListingsScreen extends StatefulWidget {
  const LandListingsScreen({super.key});

  @override
  State<LandListingsScreen> createState() => _LandListingsScreenState();
}

class _LandListingsScreenState extends State<LandListingsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedProvince = 'All';
  String _selectedDistrict = 'All';
  double _minPrice = 0;
  double _maxPrice = 1000000;
  double _minArea = 0;
  double _maxArea = 100;

  final List<String> _categories = [
    'All',
    'Paddy',
    'Vegetable',
    'Orchard',
    'Pasture',
  ];
  List<String> _provinces = ['All'];
  List<String> _districts = ['All'];
  NepalLocationResponse? _nepalLocationData;

  @override
  void initState() {
    super.initState();
    _loadNepalLocationData();
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

  Future<void> _loadNepalLocationData() async {
    try {
      final String response = await rootBundle.loadString('assets/nepal_location.json');
      final data = json.decode(response);
      setState(() {
        _nepalLocationData = NepalLocationResponse.fromJson(data);
        _provinces = ['All', ..._nepalLocationData!.provinceList.map((p) => p.nameEn)];
      });
    } catch (e) {
      debugPrint('Error loading nepal location data: $e');
    }
  }

  void _onProvinceChanged(String province) {
    setState(() {
      _selectedProvince = province;
      if (_nepalLocationData != null && province != 'All') {
        final selectedProv = _nepalLocationData!.provinceList.firstWhere(
          (p) => p.nameEn == province,
        );
        _districts = ['All', ...selectedProv.districtList.map((d) => d.nameEn)];
      } else {
        _districts = ['All'];
      }
      _selectedDistrict = 'All';
    });
  }

  List<LandModel> _applyFiltersToList(List<LandModel> allLands) {
    List<LandModel> result = List.from(allLands);
    if (_selectedCategory != 'All') {
      result = result.where((l) => l.category == _selectedCategory).toList();
    }
    if (_selectedProvince != 'All') {
      result = result.where((l) => l.province == _selectedProvince).toList();
    }
    if (_selectedDistrict != 'All') {
      result = result.where((l) => l.district == _selectedDistrict).toList();
    }
    // Price range filter
    result = result
        .where((l) =>
            l.leasePriceMonthly >= _minPrice && l.leasePriceMonthly <= _maxPrice)
        .toList();
    // Area range filter
    result = result
        .where((l) => l.areaRopani >= _minArea && l.areaRopani <= _maxArea)
        .toList();
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
    final t = AppLocalizations.of(context);

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
                      onProvinceChanged: _onProvinceChanged,
                      selectedDistrict: _selectedDistrict,
                      districts: _districts,
                      onDistrictChanged: (d) =>
                          setState(() => _selectedDistrict = d),
                      minPrice: _minPrice,
                      maxPrice: _maxPrice,
                      onPriceRangeChanged: (range) => setState(() {
                        _minPrice = range.start;
                        _maxPrice = range.end;
                      }),
                      minArea: _minArea,
                      maxArea: _maxArea,
                      onAreaRangeChanged: (range) => setState(() {
                        _minArea = range.start;
                        _maxArea = range.end;
                      }),
                      nepalLocationData: _nepalLocationData,
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
                        t.recommendedLands,
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
                                  nepalLocationData: _nepalLocationData,
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
                                t.allListings,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '${filteredLands.length} ${t.landsAvailable}',
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
                                  t.sort,
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
                          title: t.noLandsFound,
                          subtitle: t.noLandsSubtitle,
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
                            nepalLocationData: _nepalLocationData,
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
                                nepalLocationData: _nepalLocationData,
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
