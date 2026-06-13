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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
              ),
              child: TextField(
                controller: _controller,
                onChanged: widget.onSearch,
                style: GoogleFonts.plusJakartaSans(fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: t.searchByDistrict,
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: theme.colorScheme.outline,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    child: CustomIconWidget(
                      iconName: 'search',
                      color: theme.colorScheme.outline,
                      size: 20,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
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
          InkWell(
            onTap: _showFilterSheet,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CustomIconWidget(
                  iconName: 'tune',
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

  void _onLanguageChanged() {
    setState(() {});
  }

  String _getTranslatedName(String name, AppLocalizations t) {
    if (name == 'All') return t.all;
    
    // Try to find in province list first
    if (widget.nepalLocationData != null) {
      for (final province in widget.nepalLocationData!.provinceList) {
        if (province.nameEn == name) {
          if (LanguageController.instance.isNepali && province.nameNp != null) {
            return province.nameNp!;
          }
          return province.nameEn;
        }
        
        // Check districts in this province
        for (final district in province.districtList) {
          if (district.nameEn == name) {
            if (LanguageController.instance.isNepali && district.nameNp != null) {
              return district.nameNp!;
            }
            return district.nameEn;
          }
          
          // Check municipalities in this district
          for (final municipality in district.municipalityList) {
            if (municipality.nameEn == name) {
              if (LanguageController.instance.isNepali && municipality.nameNp != null) {
                return municipality.nameNp!;
              }
              return municipality.nameEn;
            }
          }
        }
      }
    }
    
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withAlpha(77),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.filterLands,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onProvinceChanged(_selectedProvince);
                    widget.onDistrictChanged(_selectedDistrict);
                    widget.onPriceRangeChanged(_priceRange);
                    widget.onAreaRangeChanged(_areaRange);
                    Navigator.pop(context);
                  },
                  child: Text(
                    t.apply,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Province filter
            Text(
              t.province,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.provinces.map((p) {
                final isSelected = p == _selectedProvince;
                return InkWell(
                  onTap: () => setState(() => _selectedProvince = p),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _getTranslatedName(p, t),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppTheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // District filter
            Text(
              t.district,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.districts.map((d) {
                final isSelected = d == _selectedDistrict;
                return InkWell(
                  onTap: () => setState(() => _selectedDistrict = d),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _getTranslatedName(d, t),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppTheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Price range filter
            Text(
              t.priceRangeMonthly,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Rs. ${_priceRange.start.toInt()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '-',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Rs. ${_priceRange.end.toInt()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 1000000,
              divisions: 100,
              activeColor: AppTheme.primary,
              inactiveColor: theme.colorScheme.outlineVariant,
              onChanged: (values) => setState(() => _priceRange = values),
            ),
            const SizedBox(height: 16),
            // Area range filter
            Text(
              t.areaRangeRopani,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_areaRange.start.toInt()} ${t.ropani}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '-',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_areaRange.end.toInt()} ${t.ropani}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: _areaRange,
              min: 0,
              max: 100,
              divisions: 100,
              activeColor: AppTheme.primary,
              inactiveColor: theme.colorScheme.outlineVariant,
              onChanged: (values) => setState(() => _areaRange = values),
            ),
          ],
        ),
      ),
    );
  }
}
