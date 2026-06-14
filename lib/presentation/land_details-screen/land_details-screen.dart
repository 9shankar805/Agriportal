import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../core/app_localizations.dart';
import '../../core/firestore_service.dart';
import '../../core/user_session.dart';
import '../../models/nepal_location_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/location_picker_widget.dart';
import '../../widgets/status_badge_widget.dart';
import '../land_listings_screen/land_listings_screen.dart';
import './widgets/customize_options_widget.dart';
import './widgets/detail_action_bar_widget.dart';
import './widgets/details_hero_widget.dart';
import './widgets/land_amenities_widget.dart';
import './widgets/land_specs_widget.dart';
import './widgets/owner_contact_widget.dart';
import './widgets/similar_lands_widget.dart';
import './widgets/virtual_tour_widget.dart';

class LandDetailScreen extends StatefulWidget {
  final String landId;
  const LandDetailScreen({required this.landId, super.key});

  @override
  State<LandDetailScreen> createState() => _LandDetailScreenState();
}

class _LandDetailScreenState extends State<LandDetailScreen> {
  bool _isLoading = true;
  bool _isSaved = false;
  LandModel? _land;
  bool _applicationSubmitted = false;
  String _ownerId = '';
  String _ownerName = '';
  NepalLocationResponse? _nepalLocationData;

  @override
  void initState() {
    super.initState();
    _loadLand();
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
      final String response = await rootBundle.loadString(
        'assets/nepal_location.json',
      );
      final data = json.decode(response);
      if (mounted) {
        setState(() {
          _nepalLocationData = NepalLocationResponse.fromJson(data);
        });
      }
    } catch (e) {
      debugPrint('Error loading nepal location data: $e');
    }
  }

  String _getTranslatedName(String nameEn) {
    if (_nepalLocationData == null) return nameEn;

    for (final province in _nepalLocationData!.provinceList) {
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
            if (LanguageController.instance.isNepali &&
                municipality.nameNp != null) {
              return municipality.nameNp!;
            }
            return municipality.nameEn;
          }
        }
      }
    }

    return nameEn;
  }

  Future<void> _loadLand() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('lands')
          .doc(widget.landId)
          .get();
      if (doc.exists && mounted) {
        final land = LandModel.fromFirestore(doc);
        final data = doc.data()!;
        setState(() {
          _land = land;
          _ownerId = data['ownerId'] as String? ?? '';
          _ownerName = data['ownerName'] as String? ?? '';
          _isLoading = false;
        });
        // Load saved status separately — don't let it block the main load
        _loadSavedStatus();
        return;
      }
    } catch (e) {
      debugPrint('[LandDetail] _loadLand error: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadSavedStatus() async {
    try {
      final isSaved = await FirestoreService.instance.isLandSaved(
        widget.landId,
      );
      if (mounted) setState(() => _isSaved = isSaved);
    } catch (_) {
      // Not critical — user may not be signed in
    }
  }

  /// Apply with KYC gate — checks kycStatus before showing the form
  Future<void> _onApplyNow() async {
    final uid = UserSession.instance.uid;
    if (uid.isEmpty) {
      _showKycDialog(
        'Sign In Required',
        'Please sign in to apply for land listings.',
      );
      return;
    }

    // Fetch the user's KYC status from Firestore
    final userData = await FirestoreService.instance.getUser(uid);
    final kycStatus = userData?['kycStatus'] as String? ?? 'pending';

    if (!mounted) return;

    if (kycStatus != 'verified') {
      _showKycDialog(
        'KYC Verification Required',
        kycStatus == 'pending'
            ? 'Your KYC is under review. You can apply once our admin team approves your documents (1–2 business days).'
            : 'You need to complete KYC verification before applying for any land. Tap below to start.',
        showKycButton: kycStatus != 'pending',
      );
      return;
    }

    _showApplicationSheet();
  }

  void _showKycDialog(
    String title,
    String message, {
    bool showKycButton = false,
  }) {
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              t.ok,
              style: GoogleFonts.plusJakartaSans(color: AppTheme.primary),
            ),
          ),
          if (showKycButton)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push(AppRoutes.kycVerification);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                t.verifyNow,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Toggle save/unsave — persists to Firestore
  Future<void> _onSave() async {
    if (UserSession.instance.uid.isEmpty || _land == null) return;
    final t = AppLocalizations.of(context);
    final newSaved = !_isSaved;
    setState(() => _isSaved = newSaved);
    try {
      if (newSaved) {
        await FirestoreService.instance.saveLand(_land!.id, {
          'title': _land!.title,
          'district': _land!.district,
          'province': _land!.province,
          'areaRopani': _land!.areaRopani,
          'leasePriceMonthly': _land!.leasePriceMonthly,
          'imageUrl': _land!.imageUrl,
          'category': _land!.category,
          'isVerified': _land!.isVerified,
          'ownerRating': _land!.ownerRating,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                t.savedToYourCollection,
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
              ),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } else {
        await FirestoreService.instance.unsaveLand(_land!.id);
      }
    } catch (_) {
      // Revert on failure
      if (mounted) setState(() => _isSaved = !newSaved);
    }
  }

  void _showApplicationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ApplicationSheet(
        landId: _land!.id,
        landTitle: _land!.title,
        ownerId: _ownerId,
        ownerName: _ownerName,
        onSubmit: () {
          Navigator.pop(ctx);
          setState(() => _applicationSubmitted = true);
          _showSuccessSnack();
        },
      ),
    );
  }

  void _showSuccessSnack() {
    final t = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              t.applicationSubmittedSuccess,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_land == null) {
      final t = AppLocalizations.of(context);
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: theme.colorScheme.onSurface,
              size: 22,
            ),
          ),
        ),
        body: Center(child: Text(t.landNotFound)),
      );
    }

    return isTablet ? _buildTabletLayout(theme) : _buildPhoneLayout(theme);
  }

  Widget _buildPhoneLayout(ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero image as SliverToBoxAdapter (fixed proportion ~40vh)
              SliverToBoxAdapter(
                child: DetailHeroWidget(
                  land: _land!,
                  isSaved: _isSaved,
                  onSave: _onSave,
                  onBack: () => context.pop(),
                ),
              ),
              // Scrollable content
              SliverToBoxAdapter(
                child: Container(
                  color: theme.scaffoldBackgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + price row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildTitlePriceRow(theme),
                      ),
                      // Location row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: _buildLocationRow(theme),
                      ),
                      // Specs chips
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: LandSpecsWidget(land: _land!),
                      ),
                      // Description
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildDescription(theme),
                      ),
                      // Location map
                      if (_land!.latitude != null && _land!.longitude != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: LandLocationMapWidget(
                            latitude: _land!.latitude!,
                            longitude: _land!.longitude!,
                            locationLabel:
                                '${_land!.municipality}, ${_land!.district}',
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: _buildNoLocationCard(theme),
                        ),
                      // Owner contact
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: OwnerContactWidget(
                          land: _land!,
                          ownerId: _ownerId,
                        ),
                      ),
                      // Virtual tour / photo gallery
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: VirtualTourWidget(land: _land!),
                      ),
                      // Amenities grid
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                        child: LandAmenitiesWidget(land: _land!),
                      ),
                      // Customize / crop options
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: CustomizeOptionsWidget(
                          category: _land!.category,
                        ),
                      ),
                      // Similar lands
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: SimilarLandsWidget(currentLandId: _land!.id),
                      ),
                      // Bottom padding for action bar
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Fixed bottom action bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DetailActionBarWidget(
              applicationSubmitted: _applicationSubmitted,
              onApply: () => _onApplyNow(),
              onSave: () => _onSave(),
              isSaved: _isSaved,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'arrow_back',
                color: theme.colorScheme.onSurface,
                size: 18,
              ),
            ),
          ),
        ),
        title: Text(
          _land!.title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _onSave,
            icon: CustomIconWidget(
              iconName: _isSaved ? 'favorite' : 'favorite_border',
              color: _isSaved
                  ? const Color(0xFFE53935)
                  : theme.colorScheme.onSurface,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: hero image
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DetailHeroWidget(
                    land: _land!,
                    isSaved: _isSaved,
                    onSave: _onSave,
                    onBack: () => context.pop(),
                    isTablet: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: VirtualTourWidget(land: _land!),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: LandAmenitiesWidget(land: _land!),
                  ),
                ],
              ),
            ),
          ),
          // Right: scrollable details
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitlePriceRow(theme),
                  const SizedBox(height: 8),
                  _buildLocationRow(theme),
                  const SizedBox(height: 12),
                  LandSpecsWidget(land: _land!),
                  const SizedBox(height: 16),
                  _buildDescription(theme),
                  const SizedBox(height: 16),
                  if (_land!.latitude != null && _land!.longitude != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: LandLocationMapWidget(
                        latitude: _land!.latitude!,
                        longitude: _land!.longitude!,
                        locationLabel:
                            '${_land!.municipality}, ${_land!.district}',
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildNoLocationCard(theme),
                    ),
                  OwnerContactWidget(land: _land!, ownerId: _ownerId),
                  const SizedBox(height: 16),
                  CustomizeOptionsWidget(category: _land!.category),
                  const SizedBox(height: 16),
                  SimilarLandsWidget(currentLandId: _land!.id),
                  const SizedBox(height: 24),
                  DetailActionBarWidget(
                    applicationSubmitted: _applicationSubmitted,
                    onApply: () => _onApplyNow(),
                    onSave: _onSave,
                    isSaved: _isSaved,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitlePriceRow(ThemeData theme) {
    final t = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _land!.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              if (_land!.isVerified)
                StatusBadgeWidget(status: BadgeStatus.verified),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'NPR ${_land!.leasePriceMonthly.toStringAsFixed(0)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              t.perMonth,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationRow(ThemeData theme) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'location_on',
          color: AppTheme.primary,
          size: 16,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${_getTranslatedName(_land!.municipality)}, ${_getTranslatedName(_land!.district)}, ${_getTranslatedName(_land!.province)} Province',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: theme.colorScheme.outline,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme) {
    final t = AppLocalizations.of(context);
    final soil = _land!.soilType.isNotEmpty
        ? _land!.soilType.toLowerCase()
        : 'fertile';
    final water = _land!.waterSource.isNotEmpty
        ? _land!.waterSource.toLowerCase()
        : 'natural sources';
    final cat = _land!.category.isNotEmpty
        ? _land!.category.toLowerCase()
        : 'agricultural';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.aboutThisLand,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This $cat land in ${_land!.district.isNotEmpty ? _land!.district : _land!.province} offers ${_land!.areaRopani} ropani of $soil soil. '
          'Water supply is from $water, making it suitable for cultivation. '
          '${_land!.hasIrrigation ? "Full irrigation infrastructure is in place. " : ""}'
          'Lease duration is flexible and negotiable with the landowner.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withAlpha(191),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        // Key facts chips row
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FactChip(icon: 'straighten', label: '${_land!.areaRopani} Ropani'),
            _FactChip(
              icon: 'terrain',
              label: _land!.soilType.isNotEmpty
                  ? _land!.soilType
                  : 'Mixed Soil',
            ),
            _FactChip(
              icon: 'water_drop',
              label: _land!.waterSource.isNotEmpty
                  ? _land!.waterSource
                  : 'Natural',
            ),
            if (_land!.hasIrrigation)
              _FactChip(icon: 'water', label: t.irrigated),
            _FactChip(
              icon: 'category',
              label: _land!.category.isNotEmpty ? _land!.category : 'General',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoLocationCard(ThemeData theme) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'location_off',
            color: theme.colorScheme.outline,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            t.exactLocationNotProvided,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fact chip — small info pill used in description section
// ─────────────────────────────────────────────────────────────────────────────

class _FactChip extends StatelessWidget {
  final String icon;
  final String label;

  const _FactChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(iconName: icon, color: AppTheme.primary, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// Application bottom sheet
class _ApplicationSheet extends StatefulWidget {
  final String landId;
  final String landTitle;
  final String ownerId;
  final String ownerName;
  final VoidCallback onSubmit;

  const _ApplicationSheet({
    required this.landId,
    required this.landTitle,
    required this.ownerId,
    required this.ownerName,
    required this.onSubmit,
  });

  @override
  State<_ApplicationSheet> createState() => _ApplicationSheetState();
}

class _ApplicationSheetState extends State<_ApplicationSheet> {
  // TODO: Replace with [Riverpod/Bloc] for production
  final _formKey = GlobalKey<FormState>();
  final _experienceController = TextEditingController();
  final _cropsController = TextEditingController();
  final _proposalController = TextEditingController();
  int _experienceYears = 1;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _experienceController.dispose();
    _cropsController.dispose();
    _proposalController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await FirestoreService.instance.applyForLand(
        landId: widget.landId,
        landTitle: widget.landTitle,
        ownerId: widget.ownerId,
        ownerName: widget.ownerName,
        message:
            '${_cropsController.text.trim()} — ${_proposalController.text.trim()}',
      );
      if (mounted) {
        setState(() => _isSubmitting = false);
        widget.onSubmit();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.submissionFailed} $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
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
              const SizedBox(height: 16),
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'agriculture',
                        color: AppTheme.primary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.submitApplication,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.landTitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: theme.colorScheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info_outline',
                      color: AppTheme.warning,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.yourContactDetailsRemainPrivate,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Years of experience
              Text(
                t.farmingExperience,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (i) {
                  final val = i + 1;
                  final isSelected = val == _experienceYears;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _experienceYears = val),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$val+',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              val > 1 ? t.years : t.year,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                color: isSelected
                                    ? Colors.white.withAlpha(204)
                                    : theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              // Intended crops
              TextFormField(
                controller: _cropsController,
                style: GoogleFonts.plusJakartaSans(fontSize: 14),
                decoration: InputDecoration(
                  labelText: t.intendedCrops,
                  hintText: t.cropsHint,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: CustomIconWidget(
                      iconName: 'grass',
                      color: AppTheme.primary,
                      size: 18,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? t.pleaseEnterIntendedCrops
                    : null,
              ),
              const SizedBox(height: 12),
              // Proposal message
              TextFormField(
                controller: _proposalController,
                style: GoogleFonts.plusJakartaSans(fontSize: 14),
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: t.proposalMessage,
                  hintText: t.proposalHint,
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.length < 20)
                    ? t.pleaseWriteAtLeast20Characters
                    : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'send',
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              t.submitApplication,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
