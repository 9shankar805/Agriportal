import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../core/app_localizations.dart';
import '../../../models/nepal_location_model.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class SearchFilterWidget extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final String selectedProvince;
  final List<String> provinces;
  final ValueChanged<String> onProvinceChanged;
  final String selectedDistrict;
  final List<String> districts;
  final ValueChanged<String> onDistrictChanged;
  final double minPrice;
  final double maxPrice;
  final ValueChanged<RangeValues> onPriceRangeChanged;
  final double minArea;
  final double maxArea;
  final ValueChanged<RangeValues> onAreaRangeChanged;
  final NepalLocationResponse? nepalLocationData;

  const SearchFilterWidget({
    required this.onSearch,
    required this.selectedProvince,
    required this.provinces,
    required this.onProvinceChanged,
    required this.selectedDistrict,
    required this.districts,
    required this.onDistrictChanged,
    required this.minPrice,
    required this.maxPrice,
    required this.onPriceRangeChanged,
    required this.minArea,
    required this.maxArea,
    required this.onAreaRangeChanged,
    this.nepalLocationData,
    super.key,
  });

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      widget.selectedProvince != 'All' ||
      widget.selectedDistrict != 'All' ||
      widget.minPrice > 0 ||
      widget.maxPrice < 1000000 ||
      widget.minArea > 0 ||
      widget.maxArea < 100;

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _FilterBottomSheet(
        provinces: widget.provinces,
        selectedProvince: widget.selectedProvince,
        onProvinceChanged: widget.onProvinceChanged,
        districts: widget.districts,
        selectedDistrict: widget.selectedDistrict,
        onDistrictChanged: widget.onDistrictChanged,
        minPrice: widget.minPrice,
        maxPrice: widget.maxPrice,
        onPriceRangeChanged: widget.onPriceRangeChanged,
        minArea: widget.minArea,
        maxArea: widget.maxArea,
        onAreaRangeChanged: widget.onAreaRangeChanged,
        nepalLocationData: widget.nepalLocationData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // ── Search field ─────────────────────────────────────────────────
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isFocused
                      ? AppTheme.primary
                      : theme.colorScheme.outlineVariant,
                  width: _isFocused ? 1.5 : 1,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withAlpha(30),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: widget.onSearch,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: t.searchByDistrict,
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: theme.colorScheme.outline,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    child: CustomIconWidget(
                      iconName: 'search',
                      color: _isFocused
                          ? AppTheme.primary
                          : theme.colorScheme.outline,
                      size: 19,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _controller.clear();
                            widget.onSearch('');
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: CustomIconWidget(
                              iconName: 'cancel',
                              color: theme.colorScheme.outline,
                              size: 17,
                            ),
                          ),
                        )
                      : null,
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  filled: false,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Filter button ────────────────────────────────────────────────
          GestureDetector(
            onTap: _showFilterSheet,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _hasActiveFilters
                        ? AppTheme.primary
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _hasActiveFilters
                          ? AppTheme.primary
                          : theme.colorScheme.outlineVariant,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _hasActiveFilters
                            ? AppTheme.primary.withAlpha(50)
                            : Colors.black.withAlpha(10),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'tune',
                      color: _hasActiveFilters
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                ),
                if (_hasActiveFilters)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _FilterBottomSheet extends StatefulWidget {
  final List<String> provinces;
  final String selectedProvince;
  final ValueChanged<String> onProvinceChanged;
  final List<String> districts;
  final String selectedDistrict;
  final ValueChanged<String> onDistrictChanged;
  final double minPrice;
  final double maxPrice;
  final ValueChanged<RangeValues> onPriceRangeChanged;
  final double minArea;
  final double maxArea;
  final ValueChanged<RangeValues> onAreaRangeChanged;
  final NepalLocationResponse? nepalLocationData;

  const _FilterBottomSheet({
    required this.provinces,
    required this.selectedProvince,
    required this.onProvinceChanged,
    required this.districts,
    required this.selectedDistrict,
    required this.onDistrictChanged,
    required this.minPrice,
    required this.maxPrice,
    required this.onPriceRangeChanged,
    required this.minArea,
    required this.maxArea,
    required this.onAreaRangeChanged,
    this.nepalLocationData,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String _selectedProvince;
  late String _selectedDistrict;
  late RangeValues _priceRange;
  late RangeValues _areaRange;

  @override
  void initState() {
    super.initState();
    _selectedProvince = widget.selectedProvince;
    _selectedDistrict = widget.selectedDistrict;
    _priceRange = RangeValues(widget.minPrice, widget.maxPrice);
    _areaRange = RangeValues(widget.minArea, widget.maxArea);
    LanguageController.instance.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageController.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() => setState(() {});

  String _getTranslatedName(String name, AppLocalizations t) {
    if (name == 'All') return t.all;
    if (widget.nepalLocationData != null) {
      for (final province in widget.nepalLocationData!.provinceList) {
        if (province.nameEn == name) {
          return (LanguageController.instance.isNepali && province.nameNp != null)
              ? province.nameNp!
              : province.nameEn;
        }
        for (final district in province.districtList) {
          if (district.nameEn == name) {
            return (LanguageController.instance.isNepali && district.nameNp != null)
                ? district.nameNp!
                : district.nameEn;
          }
        }
      }
    }
    return name;
  }

  void _applyAndClose() {
    widget.onProvinceChanged(_selectedProvince);
    widget.onDistrictChanged(_selectedDistrict);
    widget.onPriceRangeChanged(_priceRange);
    widget.onAreaRangeChanged(_areaRange);
    Navigator.pop(context);
  }

  void _resetAll() {
    setState(() {
      _selectedProvince = 'All';
      _selectedDistrict = 'All';
      _priceRange = const RangeValues(0, 1000000);
      _areaRange = const RangeValues(0, 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);
    final maxH = MediaQuery.of(context).size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle + header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'tune',
                          color: AppTheme.primary,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.filterLands,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            t.narrowDownYourSearch,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _resetAll,
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        t.reset,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
              ],
            ),
          ),

          // ── Scrollable filters ───────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Province
                  _SectionLabel(label: t.province),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.provinces.map((p) {
                      final isSelected = p == _selectedProvince;
                      return _FilterChip(
                        label: _getTranslatedName(p, t),
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedProvince = p),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // District
                  _SectionLabel(label: t.district),
                  const SizedBox(height: 10),
                  widget.districts.length <= 1
                      ? Text(
                          'Select a province first',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: theme.colorScheme.outline,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.districts.map((d) {
                            final isSelected = d == _selectedDistrict;
                            return _FilterChip(
                              label: _getTranslatedName(d, t),
                              isSelected: isSelected,
                              onTap: () =>
                                  setState(() => _selectedDistrict = d),
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 24),

                  // Price range
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionLabel(label: t.priceRangeMonthly),
                      Text(
                        'Rs. ${_priceRange.start.toInt()} – Rs. ${_priceRange.end.toInt()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.primary,
                      inactiveTrackColor:
                          theme.colorScheme.outlineVariant,
                      thumbColor: AppTheme.primary,
                      overlayColor: AppTheme.primary.withAlpha(30),
                      trackHeight: 4,
                    ),
                    child: RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 1000000,
                      divisions: 100,
                      onChanged: (v) => setState(() => _priceRange = v),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Area range
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionLabel(label: t.areaRangeRopani),
                      Text(
                        '${_areaRange.start.toInt()} – ${_areaRange.end.toInt()} ${t.ropani}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.primary,
                      inactiveTrackColor:
                          theme.colorScheme.outlineVariant,
                      thumbColor: AppTheme.primary,
                      overlayColor: AppTheme.primary.withAlpha(30),
                      trackHeight: 4,
                    ),
                    child: RangeSlider(
                      values: _areaRange,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: (v) => setState(() => _areaRange = v),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Apply button ─────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _applyAndClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.apply,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0.1,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? AppTheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
