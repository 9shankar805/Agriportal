import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../core/firestore_service.dart';
import '../../core/imgbb_service.dart';
import '../../core/user_session.dart';
import '../../core/wallet_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_image_widget.dart';
import '../../widgets/status_badge_widget.dart';
// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

enum LandStatus { active, pending, inactive, rejected }

class OwnerLand {
  final String id;
  String title;
  String district;
  String province;
  String municipality;
  double areaRopani;
  double leasePriceMonthly;
  String imageUrl;
  String semanticLabel;
  String soilType;
  String waterSource;
  bool hasIrrigation;
  String category;
  LandStatus status;
  List<LandApplicant> applicants;

  OwnerLand({
    required this.id,
    required this.title,
    required this.district,
    required this.province,
    required this.municipality,
    required this.areaRopani,
    required this.leasePriceMonthly,
    required this.imageUrl,
    required this.semanticLabel,
    required this.soilType,
    required this.waterSource,
    required this.hasIrrigation,
    required this.category,
    required this.status,
    required this.applicants,
  });

  int get totalApplications => applicants.length;
  int get pendingApplications =>
      applicants.where((a) => a.status == ApplicantStatus.pending).length;
  double get monthlyRevenue =>
      status == LandStatus.active ? leasePriceMonthly : 0;

  BadgeStatus get badgeStatus {
    switch (status) {
      case LandStatus.active:
        return BadgeStatus.approved;
      case LandStatus.pending:
        return BadgeStatus.pending;
      case LandStatus.rejected:
        return BadgeStatus.rejected;
      case LandStatus.inactive:
        return BadgeStatus.underReview;
    }
  }

  OwnerLand copyWith({
    String? title,
    String? district,
    String? province,
    String? municipality,
    double? areaRopani,
    double? leasePriceMonthly,
    String? imageUrl,
    String? semanticLabel,
    String? soilType,
    String? waterSource,
    bool? hasIrrigation,
    String? category,
    LandStatus? status,
    List<LandApplicant>? applicants,
  }) {
    return OwnerLand(
      id: id,
      title: title ?? this.title,
      district: district ?? this.district,
      province: province ?? this.province,
      municipality: municipality ?? this.municipality,
      areaRopani: areaRopani ?? this.areaRopani,
      leasePriceMonthly: leasePriceMonthly ?? this.leasePriceMonthly,
      imageUrl: imageUrl ?? this.imageUrl,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      soilType: soilType ?? this.soilType,
      waterSource: waterSource ?? this.waterSource,
      hasIrrigation: hasIrrigation ?? this.hasIrrigation,
      category: category ?? this.category,
      status: status ?? this.status,
      applicants: applicants ?? this.applicants,
    );
  }
}

enum ApplicantStatus { pending, approved, rejected }

class LandApplicant {
  final String id;
  final String name;
  final String phone;
  final int experienceYears;
  final String intendedCrops;
  final String proposal;
  final String appliedDate;
  ApplicantStatus status;

  LandApplicant({
    required this.id,
    required this.name,
    required this.phone,
    required this.experienceYears,
    required this.intendedCrops,
    required this.proposal,
    required this.appliedDate,
    required this.status,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class MyLandsScreen extends StatefulWidget {
  const MyLandsScreen({super.key});

  @override
  State<MyLandsScreen> createState() => _MyLandsScreenState();
}

class _MyLandsScreenState extends State<MyLandsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  late List<OwnerLand> _lands;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _lands = [];
    _loadFromFirestore();
  }

  Future<void> _loadFromFirestore() async {
    final uid = UserSession.instance.uid;
    if (uid.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      FirestoreService.instance.myLandsStream().listen((snap) {
        if (!mounted) return;
        final firestoreLands = snap.docs.map((doc) {
          final d = doc.data() as Map<String, dynamic>;
          final statusStr = d['status'] as String? ?? 'pending';
          final landStatus = {
            'active':   LandStatus.active,
            'inactive': LandStatus.inactive,
            'rejected': LandStatus.rejected,
          }[statusStr] ?? LandStatus.pending;

          return OwnerLand(
            id:               doc.id,
            title:            d['title']           as String? ?? '',
            district:         d['district']        as String? ?? d['location'] as String? ?? '',
            province:         d['province']        as String? ?? '',
            municipality:     d['municipality']    as String? ?? '',
            areaRopani:       (d['areaBigha']      as num? ?? d['area'] as num? ?? 0).toDouble(),
            leasePriceMonthly:(d['pricePerBigha']  as num? ?? d['price'] as num? ?? 0).toDouble(),
            imageUrl:         d['imageUrl']        as String? ?? '',
            semanticLabel:    d['title']           as String? ?? '',
            soilType:         d['soilType']        as String? ?? '',
            waterSource:      d['waterSource']     as String? ?? '',
            hasIrrigation:    d['hasIrrigation']   as bool? ?? false,
            category:         d['category']        as String? ?? 'Other',
            status:           landStatus,
            applicants:       [],
          );
        }).toList();
        setState(() {
          _lands = firestoreLands;
          _isLoading = false;
        });
      }, onError: (_) {
        if (mounted) setState(() => _isLoading = false);
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Computed lists ─────────────────────────────────────────────────────────
  List<OwnerLand> get _allLands => _lands;
  List<OwnerLand> get _activeLands =>
      _lands.where((l) => l.status == LandStatus.active).toList();
  List<OwnerLand> get _pendingLands =>
      _lands.where((l) => l.status == LandStatus.pending).toList();
  List<OwnerLand> get _inactiveLands =>
      _lands.where((l) => l.status == LandStatus.inactive || l.status == LandStatus.rejected).toList();

  int get _totalApplications =>
      _lands.fold(0, (s, l) => s + l.totalApplications);
  int get _pendingApplicationsCount =>
      _lands.fold(0, (s, l) => s + l.pendingApplications);
  double get _totalMonthlyRevenue =>
      _lands.fold(0.0, (s, l) => s + l.monthlyRevenue);

  // ── Mutations ──────────────────────────────────────────────────────────────

  void _addLand(OwnerLand land) {
    setState(() => _lands.add(land));
    // Persist to Firestore
    FirestoreService.instance.addLand({
      'title':          land.title,
      'district':       land.district,
      'province':       land.province,
      'municipality':   land.municipality,
      'areaBigha':      land.areaRopani,
      'pricePerBigha':  land.leasePriceMonthly,
      'imageUrl':       land.imageUrl,
      'soilType':       land.soilType,
      'waterSource':    land.waterSource,
      'hasIrrigation':  land.hasIrrigation,
      'category':       land.category,
      'status':         'pending',
      'ownerName':      UserSession.instance.displayName,
    }).then((_) {}).catchError((_) {});
  }

  void _updateLand(OwnerLand updated) {
    setState(() {
      final idx = _lands.indexWhere((l) => l.id == updated.id);
      if (idx != -1) _lands[idx] = updated;
    });
    FirestoreService.instance.updateLand(updated.id, {
      'title':         updated.title,
      'district':      updated.district,
      'province':      updated.province,
      'municipality':  updated.municipality,
      'areaBigha':     updated.areaRopani,
      'pricePerBigha': updated.leasePriceMonthly,
      'soilType':      updated.soilType,
      'waterSource':   updated.waterSource,
      'hasIrrigation': updated.hasIrrigation,
      'category':      updated.category,
    }).catchError((_) {});
  }

  void _deleteLand(String id) {
    setState(() => _lands.removeWhere((l) => l.id == id));
    FirestoreService.instance.deleteLand(id).catchError((_) {});
  }

  void _toggleActive(OwnerLand land) {
    final newStatus = land.status == LandStatus.active
        ? LandStatus.inactive
        : LandStatus.active;
    _updateLand(land.copyWith(status: newStatus));
    FirestoreService.instance.updateLand(land.id, {
      'status': newStatus == LandStatus.active ? 'active' : 'inactive',
    }).catchError((_) {});
  }

  void _updateApplicant(String landId, LandApplicant updated) {
    setState(() {
      final land = _lands.firstWhere((l) => l.id == landId);
      final idx  = land.applicants.indexWhere((a) => a.id == updated.id);
      if (idx != -1) land.applicants[idx] = updated;
    });
    // Update application status in Firestore
    final statusStr = updated.status == ApplicantStatus.approved
        ? 'approved'
        : 'rejected';
    FirestoreService.instance
        .updateApplicationStatus(updated.id, statusStr)
        .catchError((_) {});
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Check KYC + wallet balance before opening the Add Land form.
  Future<void> _openAddLandForm() async {
    // Guard: must be signed in
    if (UserSession.instance.uid.isEmpty) {
      _showSnack('Please sign in to list a land', AppTheme.warning);
      return;
    }

    // ── KYC check ──────────────────────────────────────────────────────────
    final userData = await FirestoreService.instance.getUser(UserSession.instance.uid);
    final kycStatus = userData?['kycStatus'] as String? ?? 'pending';
    if (kycStatus != 'verified') {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('KYC Verification Required',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          content: Text(
            kycStatus == 'pending'
                ? 'Your KYC is pending admin review. You can list land once approved. This usually takes 1–2 business days.'
                : 'Your KYC was not approved. Please resubmit clearer documents to list land.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Later',
                  style: GoogleFonts.plusJakartaSans(color: AppTheme.primary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.push(AppRoutes.kycVerification);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
                elevation: 0,
              ),
              child: Text(
                kycStatus == 'pending' ? 'View KYC Status' : 'Submit KYC',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
      );
      return;
    }

    double balance;
    try {
      balance = await WalletService.instance.getBalance();
    } catch (_) {
      balance = 0.0;
    }

    if (!mounted) return;

    if (balance < WalletService.listingFee) {
      // Show inline top-up sheet — no navigation needed, avoids navigator conflicts
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _WalletTopUpSheet(
          currentBalance: balance,
          onTopUpSuccess: () {
            // After adding money, re-open the land form
            Navigator.of(context).pop();
            Future.delayed(const Duration(milliseconds: 350), () {
              if (mounted) _openAddLandForm();
            });
          },
        ),
      );
      return;
    }

    // Enough balance — open the form
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LandFormSheet(
        onSave: (land) async {
          Navigator.pop(ctx);
          // Deduct listing fee from wallet
          try {
            await WalletService.instance.chargeListingFee(
              landTitle: land.title,
            );
          } catch (e) {
            _showSnack('Could not charge listing fee: $e', AppTheme.error);
            return;
          }
          _addLand(land);
          _showSnack(
            'Land listed! Rs ${WalletService.listingFee.toStringAsFixed(0)} deducted from wallet.',
            AppTheme.success,
          );
        },
      ),
    );
  }

  void _openEditLandForm(OwnerLand land) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LandFormSheet(
        existingLand: land,
        onSave: (updated) {
          Navigator.pop(ctx);
          _updateLand(updated);
          _showSnack('Listing updated', AppTheme.success);
        },
      ),
    );
  }

  void _confirmDeleteLand(OwnerLand land) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Listing?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will permanently remove "${land.title}" and all associated applications. This cannot be undone.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(color: AppTheme.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteLand(land.id);
              _showSnack('Listing deleted', AppTheme.error);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openApplicationsSheet(OwnerLand land) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ApplicationsSheet(
        land: land,
        onApplicantUpdate: (applicant) {
          Navigator.pop(ctx);
          _updateApplicant(land.id, applicant);
          _showSnack(
            applicant.status == ApplicantStatus.approved
                ? 'Applicant approved — contact details unlocked'
                : 'Applicant rejected',
            applicant.status == ApplicantStatus.approved
                ? AppTheme.success
                : AppTheme.error,
          );
        },
      ),
    );
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : NestedScrollView(
                headerSliverBuilder: (ctx, _) => [
                  SliverToBoxAdapter(child: _buildHeader(theme)),
                  SliverToBoxAdapter(child: _buildStatsRow(theme)),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: AppTheme.primary,
                        unselectedLabelColor: theme.colorScheme.outline,
                        indicatorColor: AppTheme.primary,
                        indicatorWeight: 2.5,
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                        ),
                        tabs: [
                          Tab(text: 'All (${_allLands.length})'),
                          Tab(text: 'Active (${_activeLands.length})'),
                          Tab(text: 'Pending (${_pendingLands.length})'),
                          Tab(text: 'Inactive (${_inactiveLands.length})'),
                        ],
                      ),
                      backgroundColor: theme.colorScheme.surface,
                    ),
                  ),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _LandList(
                      lands: _allLands,
                      onLandTap: (id) =>
                          context.push(AppRoutes.landDetail, extra: id),
                      onEdit: _openEditLandForm,
                      onDelete: _confirmDeleteLand,
                      onToggleActive: _toggleActive,
                      onViewApplications: _openApplicationsSheet,
                      onAddLand: () => _openAddLandForm(),
                    ),
                    _LandList(
                      lands: _activeLands,
                      onLandTap: (id) =>
                          context.push(AppRoutes.landDetail, extra: id),
                      onEdit: _openEditLandForm,
                      onDelete: _confirmDeleteLand,
                      onToggleActive: _toggleActive,
                      onViewApplications: _openApplicationsSheet,
                      onAddLand: () => _openAddLandForm(),
                    ),
                    _LandList(
                      lands: _pendingLands,
                      onLandTap: (id) =>
                          context.push(AppRoutes.landDetail, extra: id),
                      onEdit: _openEditLandForm,
                      onDelete: _confirmDeleteLand,
                      onToggleActive: _toggleActive,
                      onViewApplications: _openApplicationsSheet,
                      onAddLand: () => _openAddLandForm(),
                    ),
                    _LandList(
                      lands: _inactiveLands,
                      onLandTap: (id) =>
                          context.push(AppRoutes.landDetail, extra: id),
                      onEdit: _openEditLandForm,
                      onDelete: _confirmDeleteLand,
                      onToggleActive: _toggleActive,
                      onViewApplications: _openApplicationsSheet,
                      onAddLand: () => _openAddLandForm(),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddLandForm(),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: CustomIconWidget(iconName: 'add', color: Colors.white, size: 20),
        label: Text(
          'List Land',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── Advanced LandOwner Top Bar ─────────────────────────────────────────────
  Widget _buildHeader(ThemeData theme) {
    final user = UserSession.instance.firebaseUser;
    final name = user?.displayName ?? UserSession.instance.displayName;
    final photoUrl = user?.photoURL ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'L';
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Avatar + Name + Notif + Settings ──────────────────
          Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: () => context.go(AppRoutes.profile),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withAlpha(50),
                      backgroundImage: photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl.isEmpty
                          ? Text(initial,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ))
                          : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.white.withAlpha(180),
                      ),
                    ),
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // KYC status pill
                    FutureBuilder<Map<String, dynamic>?>(
                      future: FirestoreService.instance.getUser(UserSession.instance.uid),
                      builder: (ctx, snap) {
                        final kyc = snap.data?['kycStatus'] as String? ?? 'pending';
                        final isVerified = kyc == 'verified';
                        return Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isVerified
                                ? Colors.white.withAlpha(40)
                                : AppTheme.warning.withAlpha(200),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: isVerified ? 'verified' : 'hourglass_top',
                                color: Colors.white,
                                size: 10,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isVerified ? 'KYC Verified' : 'KYC Pending',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Notifications bell
              Stack(
                children: [
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.notifications),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'notifications_outlined',
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  if (_pendingApplicationsCount > 0)
                    Positioned(
                      top: 4, right: 4,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$_pendingApplicationsCount',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              // Settings
              GestureDetector(
                onTap: () => context.go(AppRoutes.profile),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'settings',
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Row 2: Stats chips ─────────────────────────────────────────
          Row(
            children: [
              _GradientStatChip(
                icon: 'landscape',
                value: '${_allLands.length}',
                label: 'Listings',
              ),
              const SizedBox(width: 8),
              _GradientStatChip(
                icon: 'people',
                value: '$_totalApplications',
                label: 'Applicants',
              ),
              const SizedBox(width: 8),
              _GradientStatChip(
                icon: 'pending_actions',
                value: '$_pendingApplicationsCount',
                label: 'Pending',
                highlight: _pendingApplicationsCount > 0,
              ),
              const SizedBox(width: 8),
              _GradientStatChip(
                icon: 'payments',
                value: 'NPR ${(_totalMonthlyRevenue / 1000).toStringAsFixed(0)}k',
                label: 'Revenue',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Keep _buildStatsRow returning empty (stats now inside _buildHeader)
  Widget _buildStatsRow(ThemeData theme) => const SizedBox.shrink();
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient stat chip for LandOwner header
// ─────────────────────────────────────────────────────────────────────────────

class _GradientStatChip extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final bool highlight;

  const _GradientStatChip({
    required this.icon,
    required this.value,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: highlight
              ? AppTheme.accent.withAlpha(200)
              : Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withAlpha(40),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomIconWidget(iconName: icon, color: Colors.white, size: 14),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                color: Colors.white.withAlpha(180),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab bar delegate
// ─────────────────────────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  const _TabBarDelegate(this.tabBar, {required this.backgroundColor});

  @override
  double get minExtent => tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: Column(
        children: [tabBar, const Divider(height: 1, thickness: 1)],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Land list
// ─────────────────────────────────────────────────────────────────────────────

class _LandList extends StatelessWidget {
  final List<OwnerLand> lands;
  final ValueChanged<String> onLandTap;
  final ValueChanged<OwnerLand> onEdit;
  final ValueChanged<OwnerLand> onDelete;
  final ValueChanged<OwnerLand> onToggleActive;
  final ValueChanged<OwnerLand> onViewApplications;
  final VoidCallback onAddLand;

  const _LandList({
    required this.lands,
    required this.onLandTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
    required this.onViewApplications,
    required this.onAddLand,
  });

  @override
  Widget build(BuildContext context) {
    if (lands.isEmpty) {
      return _buildEmpty(context);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: lands.length,
      itemBuilder: (context, index) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 280 + index * 55),
        curve: Curves.easeOutCubic,
        builder: (ctx, val, child) => Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - val)),
            child: child,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _LandOwnerCard(
            land: lands[index],
            onTap: () => onLandTap(lands[index].id),
            onEdit: () => onEdit(lands[index]),
            onDelete: () => onDelete(lands[index]),
            onToggleActive: () => onToggleActive(lands[index]),
            onViewApplications: () => onViewApplications(lands[index]),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'landscape',
                  color: AppTheme.primary,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Lands Here',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap "List Land" to add your first agricultural land listing.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF757575),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAddLand,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              icon: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                'List Your Land',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
// Land owner card
// ─────────────────────────────────────────────────────────────────────────────

class _LandOwnerCard extends StatelessWidget {
  final OwnerLand land;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;
  final VoidCallback onViewApplications;

  const _LandOwnerCard({
    required this.land,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
    required this.onViewApplications,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInactive =
        land.status == LandStatus.inactive || land.status == LandStatus.rejected;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isInactive ? 0.72 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(14),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // ── Image section ────────────────────────────────────────────
              Stack(
                children: [
                  CustomImageWidget(
                    imageUrl: land.imageUrl,
                    width: double.infinity,
                    height: 148,
                    fit: BoxFit.cover,
                    semanticLabel: land.semanticLabel,
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xBB000000)],
                          stops: [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: StatusBadgeWidget(status: land.badgeStatus),
                  ),
                  // Pending badge
                  if (land.pendingApplications > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warning,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'pending_actions',
                              color: Colors.white,
                              size: 11,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${land.pendingApplications} Pending',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Title + location
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          land.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'location_on',
                              color: Colors.white.withAlpha(200),
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${land.municipality}, ${land.district}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: Colors.white.withAlpha(200),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // ── Info row ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Row(
                  children: [
                    _InfoChip(
                      icon: 'straighten',
                      label: '${land.areaRopani} Ro.',
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 6),
                    _InfoChip(
                      icon: 'payments',
                      label: 'NPR ${land.leasePriceMonthly.toStringAsFixed(0)}/mo',
                      color: AppTheme.info,
                    ),
                    const Spacer(),
                    // Applicants count
                    if (land.totalApplications > 0) ...[
                      CustomIconWidget(
                        iconName: 'people',
                        color: theme.colorScheme.outline,
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${land.totalApplications}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Options menu
                    GestureDetector(
                      onTap: () => _showOptions(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'more_horiz',
                            color: theme.colorScheme.onSurface,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Quick action bar ─────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    _QuickAction(
                      icon: 'edit',
                      label: 'Edit',
                      color: AppTheme.primary,
                      onTap: onEdit,
                    ),
                    _QuickDivider(),
                    _QuickAction(
                      icon: 'people',
                      label: 'Applicants (${land.totalApplications})',
                      color: AppTheme.info,
                      onTap: onViewApplications,
                    ),
                    _QuickDivider(),
                    _QuickAction(
                      icon: land.status == LandStatus.active
                          ? 'visibility_off'
                          : 'visibility',
                      label: land.status == LandStatus.active
                          ? 'Deactivate'
                          : 'Activate',
                      color: land.status == LandStatus.active
                          ? AppTheme.warning
                          : AppTheme.success,
                      onTap: land.status == LandStatus.rejected
                          ? null
                          : onToggleActive,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OptionsSheet(
        landTitle: land.title,
        status: land.status,
        onEdit: () {
          Navigator.pop(ctx);
          onEdit();
        },
        onViewApplications: () {
          Navigator.pop(ctx);
          onViewApplications();
        },
        onToggleActive: land.status == LandStatus.rejected
            ? null
            : () {
                Navigator.pop(ctx);
                onToggleActive();
              },
        onDelete: () {
          Navigator.pop(ctx);
          onDelete();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick action button
// ─────────────────────────────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: icon,
                color: onTap == null ? Colors.grey : color,
                size: 14,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: onTap == null ? Colors.grey : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info chip
// ─────────────────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(iconName: icon, color: color, size: 11),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Options bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _OptionsSheet extends StatelessWidget {
  final String landTitle;
  final LandStatus status;
  final VoidCallback onEdit;
  final VoidCallback onViewApplications;
  final VoidCallback? onToggleActive;
  final VoidCallback onDelete;

  const _OptionsSheet({
    required this.landTitle,
    required this.status,
    required this.onEdit,
    required this.onViewApplications,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = status == LandStatus.active;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withAlpha(70),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            landTitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          _OptionTile(
            icon: 'edit',
            label: 'Edit Listing',
            color: AppTheme.primary,
            onTap: onEdit,
          ),
          _OptionTile(
            icon: 'people',
            label: 'View Applications',
            color: AppTheme.info,
            onTap: onViewApplications,
          ),
          if (onToggleActive != null)
            _OptionTile(
              icon: isActive ? 'visibility_off' : 'visibility',
              label: isActive ? 'Deactivate Listing' : 'Activate Listing',
              color: isActive ? AppTheme.warning : AppTheme.success,
              onTap: onToggleActive!,
            ),
          _OptionTile(
            icon: 'delete_outline',
            label: 'Delete Listing',
            color: AppTheme.error,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: CustomIconWidget(iconName: icon, color: color, size: 18),
        ),
      ),
      title: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color == AppTheme.error ? AppTheme.error : theme.colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Applications bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ApplicationsSheet extends StatefulWidget {
  final OwnerLand land;
  final ValueChanged<LandApplicant> onApplicantUpdate;

  const _ApplicationsSheet({
    required this.land,
    required this.onApplicantUpdate,
  });

  @override
  State<_ApplicationsSheet> createState() => _ApplicationsSheetState();
}

class _ApplicationsSheetState extends State<_ApplicationsSheet> {
  late List<LandApplicant> _applicants;

  @override
  void initState() {
    super.initState();
    _applicants = List.from(widget.land.applicants);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        0,
        16,
        0,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withAlpha(70),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Applications',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.land.title,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_applicants.length} total',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          if (_applicants.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  CustomIconWidget(
                    iconName: 'people_outline',
                    color: theme.colorScheme.outline,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No applications yet',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemCount: _applicants.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) => _ApplicantTile(
                  applicant: _applicants[i],
                  onApprove: _applicants[i].status == ApplicantStatus.pending
                      ? () => _handleApplicant(
                            _applicants[i],
                            ApplicantStatus.approved,
                          )
                      : null,
                  onReject: _applicants[i].status == ApplicantStatus.pending
                      ? () => _handleApplicant(
                            _applicants[i],
                            ApplicantStatus.rejected,
                          )
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleApplicant(LandApplicant applicant, ApplicantStatus newStatus) {
    applicant.status = newStatus;
    widget.onApplicantUpdate(applicant);
  }
}

class _ApplicantTile extends StatelessWidget {
  final LandApplicant applicant;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _ApplicantTile({
    required this.applicant,
    required this.onApprove,
    required this.onReject,
  });

  Color get _statusColor {
    switch (applicant.status) {
      case ApplicantStatus.approved:
        return AppTheme.success;
      case ApplicantStatus.rejected:
        return AppTheme.error;
      case ApplicantStatus.pending:
        return AppTheme.warning;
    }
  }

  String get _statusLabel {
    switch (applicant.status) {
      case ApplicantStatus.approved:
        return 'Approved';
      case ApplicantStatus.rejected:
        return 'Rejected';
      case ApplicantStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = applicant.status == ApplicantStatus.pending;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryContainer,
                child: Text(
                  applicant.name[0].toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'agriculture',
                          color: theme.colorScheme.outline,
                          size: 11,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${applicant.experienceYears} yrs exp · ${applicant.intendedCrops}',
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
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          // Proposal preview
          if (applicant.proposal.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                applicant.proposal,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withAlpha(180),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          // Contact row (shown when approved)
          if (applicant.status == ApplicantStatus.approved) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.success.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.success.withAlpha(60)),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'phone',
                    color: AppTheme.success,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    applicant.phone,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.success,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Contact unlocked',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: AppTheme.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Action buttons (pending only)
          if (isPending) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: BorderSide(color: AppTheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Reject',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Approve',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Applied ${applicant.appliedDate}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add / Edit Land Form
// ─────────────────────────────────────────────────────────────────────────────

class _LandFormSheet extends StatefulWidget {
  final OwnerLand? existingLand;
  final ValueChanged<OwnerLand> onSave;

  const _LandFormSheet({this.existingLand, required this.onSave});

  @override
  State<_LandFormSheet> createState() => _LandFormSheetState();
}

class _LandFormSheetState extends State<_LandFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _municipalityCtrl;
  late TextEditingController _areaCtrl;
  late TextEditingController _priceCtrl;

  // Image state — picked file or existing URL
  File? _pickedImageFile;
  String _uploadedImageUrl = '';
  bool _isUploadingImage = false;
  double _uploadProgress = 0.0;

  String _province = 'Bagmati';
  String _district = 'Chitwan';
  String _soilType = 'Alluvial';
  String _waterSource = 'River';
  String _category = 'Paddy';
  bool _hasIrrigation = false;
  bool _isSaving = false;

  static const _provinces = [
    'Koshi', 'Madhesh', 'Bagmati', 'Gandaki', 'Lumbini', 'Karnali', 'Sudurpashchim',
  ];
  static const _districts = [
    'Chitwan', 'Kavre', 'Mustang', 'Rasuwa', 'Ilam', 'Nawalpur',
    'Rupandehi', 'Solukhumbu', 'Kathmandu', 'Lalitpur', 'Bhaktapur',
  ];
  static const _soilTypes = [
    'Alluvial', 'Loamy', 'Sandy Loam', 'Clay', 'Clay Loam', 'Acidic Loam',
  ];
  static const _waterSources = [
    'River', 'Canal', 'Borewell', 'Spring', 'Stream', 'Snowmelt', 'Rainfall + Stream',
  ];
  static const _categories = ['Paddy', 'Vegetable', 'Orchard', 'Pasture', 'Mixed'];

  bool get _isEditing => widget.existingLand != null;

  @override
  void initState() {
    super.initState();
    final l = widget.existingLand;
    _titleCtrl = TextEditingController(text: l?.title ?? '');
    _municipalityCtrl = TextEditingController(text: l?.municipality ?? '');
    _areaCtrl = TextEditingController(
      text: l != null ? l.areaRopani.toString() : '',
    );
    _priceCtrl = TextEditingController(
      text: l != null ? l.leasePriceMonthly.toStringAsFixed(0) : '',
    );
    if (l != null) {
      _uploadedImageUrl = l.imageUrl;
      _province = l.province;
      _district = l.district;
      _soilType = l.soilType;
      _waterSource = l.waterSource;
      _category = l.category;
      _hasIrrigation = l.hasIrrigation;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _municipalityCtrl.dispose();
    _areaCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_isUploadingImage) {
      _showSnack('Please wait for image upload to finish');
      return;
    }
    setState(() => _isSaving = true);

    // Use uploaded URL, or existing URL, or fallback placeholder
    final finalImageUrl = _uploadedImageUrl.isNotEmpty
        ? _uploadedImageUrl
        : 'https://images.pexels.com/photos/974314/pexels-photo-974314.jpeg';

    final land = OwnerLand(
      id: widget.existingLand?.id ??
          'land_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      district: _district,
      province: _province,
      municipality: _municipalityCtrl.text.trim(),
      areaRopani: double.parse(_areaCtrl.text.trim()),
      leasePriceMonthly: double.parse(_priceCtrl.text.trim()),
      imageUrl: finalImageUrl,
      semanticLabel:
          '${_titleCtrl.text.trim()} agricultural land in $_district Nepal',
      soilType: _soilType,
      waterSource: _waterSource,
      hasIrrigation: _hasIrrigation,
      category: _category,
      status: widget.existingLand?.status ?? LandStatus.pending,
      applicants: widget.existingLand?.applicants ?? [],
    );

    Future.microtask(() {
      if (mounted) {
        setState(() => _isSaving = false);
        widget.onSave(land);
      }
    });
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.plusJakartaSans(fontSize: 13)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked == null) return;
    final file = File(picked.path);
    setState(() {
      _pickedImageFile = file;
      _isUploadingImage = true;
      _uploadProgress = 0.0;
    });
    try {
      final url = await ImgBBService.instance.uploadImage(
        file,
        name: 'land_${DateTime.now().millisecondsSinceEpoch}',
        onProgress: (p) {
          if (mounted) setState(() => _uploadProgress = p);
        },
      );
      if (mounted) {
        setState(() {
          _uploadedImageUrl = url;
          _isUploadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
          _pickedImageFile = null;
        });
        _showSnack('Upload failed: $e');
      }
    }
  }

  Widget _buildImagePickerContent() {
    final theme = Theme.of(context);

    // Uploading state
    if (_isUploadingImage) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                value: _uploadProgress > 0 ? _uploadProgress : null,
                color: AppTheme.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _uploadProgress > 0
                  ? 'Uploading... ${(_uploadProgress * 100).toInt()}%'
                  : 'Preparing...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    // Image picked locally — show preview + uploaded badge
    if (_pickedImageFile != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(_pickedImageFile!, fit: BoxFit.cover),
          Positioned(
            top: 8, right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.success,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(iconName: 'check_circle', color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text('Uploaded', style: GoogleFonts.plusJakartaSans(
                    fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white,
                  )),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 8, right: 8,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(140),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(iconName: 'edit', color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text('Change', style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white,
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Existing image from edit mode
    if (_uploadedImageUrl.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CustomImageWidget(
            imageUrl: _uploadedImageUrl,
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
            semanticLabel: 'Current land photo',
          ),
          Positioned(
            bottom: 8, right: 8,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(140),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(iconName: 'edit', color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text('Change Photo', style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white,
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Empty — prompt to pick
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: CustomIconWidget(iconName: 'add_a_photo', color: AppTheme.primary, size: 26),
          ),
        ),
        const SizedBox(height: 10),
        Text('Tap to add a photo', style: GoogleFonts.plusJakartaSans(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary,
        )),
        const SizedBox(height: 4),
        Text('Pick from gallery · Uploads automatically', style: GoogleFonts.plusJakartaSans(
          fontSize: 11, color: theme.colorScheme.outline,
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withAlpha(70),
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
                        iconName: _isEditing ? 'edit' : 'add_location_alt',
                        color: AppTheme.primary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isEditing ? 'Edit Listing' : 'List Your Land',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Land Title
              _FieldLabel('Land Title *'),
              TextFormField(
                controller: _titleCtrl,
                style: GoogleFonts.plusJakartaSans(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. Fertile Paddy Fields — Chitwan',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: CustomIconWidget(
                      iconName: 'landscape',
                      color: AppTheme.primary,
                      size: 18,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 14),

              // Province + District row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Province *'),
                        _DropdownField<String>(
                          value: _province,
                          items: _provinces,
                          onChanged: (v) => setState(() => _province = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('District *'),
                        _DropdownField<String>(
                          value: _district,
                          items: _districts,
                          onChanged: (v) => setState(() => _district = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Municipality
              _FieldLabel('Municipality *'),
              TextFormField(
                controller: _municipalityCtrl,
                style: GoogleFonts.plusJakartaSans(fontSize: 14),
                decoration: const InputDecoration(hintText: 'e.g. Bharatpur'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              // Area + Price row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Area (Ropani) *'),
                        TextFormField(
                          controller: _areaCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'),
                            ),
                          ],
                          style: GoogleFonts.plusJakartaSans(fontSize: 14),
                          decoration:
                              const InputDecoration(hintText: 'e.g. 12.5'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Required';
                            if (double.tryParse(v) == null) return 'Invalid';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Lease/Month (NPR) *'),
                        TextFormField(
                          controller: _priceCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: GoogleFonts.plusJakartaSans(fontSize: 14),
                          decoration:
                              const InputDecoration(hintText: 'e.g. 8500'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Required';
                            if (double.tryParse(v) == null) return 'Invalid';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Soil + Water row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Soil Type'),
                        _DropdownField<String>(
                          value: _soilType,
                          items: _soilTypes,
                          onChanged: (v) => setState(() => _soilType = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Water Source'),
                        _DropdownField<String>(
                          value: _waterSource,
                          items: _waterSources,
                          onChanged: (v) => setState(() => _waterSource = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Category
              _FieldLabel('Land Category'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = cat == _category;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Irrigation toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'water_drop',
                      color: AppTheme.info,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Irrigation Available',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Land has irrigation infrastructure',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _hasIrrigation,
                      onChanged: (v) => setState(() => _hasIrrigation = v),
                      activeColor: AppTheme.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Image Picker ──────────────────────────────────────────────
              _FieldLabel('Cover Photo'),
              GestureDetector(
                onTap: _isUploadingImage ? null : _pickImage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 160,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _uploadedImageUrl.isNotEmpty
                          ? AppTheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      width: _uploadedImageUrl.isNotEmpty ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildImagePickerContent(),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Save Changes' : 'Submit Listing',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                item.toString(),
                style: GoogleFonts.plusJakartaSans(fontSize: 13),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wallet top-up sheet — shown inline when balance is insufficient
// No navigation needed — avoids all go_router/navigator conflicts
// ─────────────────────────────────────────────────────────────────────────────

class _WalletTopUpSheet extends StatefulWidget {
  final double currentBalance;
  final VoidCallback onTopUpSuccess;

  const _WalletTopUpSheet({
    required this.currentBalance,
    required this.onTopUpSuccess,
  });

  @override
  State<_WalletTopUpSheet> createState() => _WalletTopUpSheetState();
}

class _WalletTopUpSheetState extends State<_WalletTopUpSheet> {
  final TextEditingController _amountCtrl = TextEditingController();
  bool _isLoading = false;
  double _balance = 0;

  static const List<double> _quickAmounts = [20, 50, 100, 200, 500];

  @override
  void initState() {
    super.initState();
    _balance = widget.currentBalance;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _addAmount(double amount) async {
    setState(() => _isLoading = true);
    try {
      await WalletService.instance.addMoney(amount, description: 'Added to wallet');
      if (mounted) {
        setState(() {
          _balance += amount;
          _isLoading = false;
        });
        _showSnack('Rs ${amount.toStringAsFixed(0)} added!', AppTheme.success);
        // If now enough, auto-trigger success
        if (_balance >= WalletService.listingFee) {
          await Future.delayed(const Duration(milliseconds: 600));
          if (mounted) widget.onTopUpSuccess();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('Failed: $e', AppTheme.error);
      }
    }
  }

  Future<void> _addCustomAmount() async {
    final text = _amountCtrl.text.trim();
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      _showSnack('Enter a valid amount', AppTheme.error);
      return;
    }
    _amountCtrl.clear();
    await _addAmount(amount);
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needed = (WalletService.listingFee - _balance).clamp(0, double.infinity);
    final hasEnough = _balance >= WalletService.listingFee;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withAlpha(70),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'account_balance_wallet',
                      color: AppTheme.error,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Insufficient Balance',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        hasEnough
                            ? 'Balance ready — tap List Land!'
                            : 'Add Rs ${needed.toStringAsFixed(0)} more to list your land',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: hasEnough ? AppTheme.success : theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Balance bar
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Balance',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      Text(
                        'Rs ${_balance.toStringAsFixed(2)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: hasEnough ? AppTheme.success : AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Required',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      Text(
                        'Rs ${WalletService.listingFee.toStringAsFixed(0)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick amounts
            Text(
              'Quick Add',
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
              children: _quickAmounts.map((amt) {
                return GestureDetector(
                  onTap: _isLoading ? null : () => _addAmount(amt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primary.withAlpha(60)),
                    ),
                    child: Text(
                      '+ Rs ${amt.toStringAsFixed(0)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Custom amount row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Custom amount',
                      prefixText: 'Rs  ',
                      prefixStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: theme.colorScheme.outline,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addCustomAmount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Add',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // List Land button (enabled only when enough balance)
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: (hasEnough && !_isLoading) ? widget.onTopUpSuccess : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  disabledBackgroundColor: AppTheme.primary.withAlpha(60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
                icon: CustomIconWidget(
                  iconName: 'landscape',
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  hasEnough
                      ? 'Continue to List Land'
                      : 'Add Rs ${needed.toStringAsFixed(0)} to Continue',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
