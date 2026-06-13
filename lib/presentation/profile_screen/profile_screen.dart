import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_localizations.dart';
import '../../core/firebase_auth_service.dart';
import '../../core/firestore_service.dart';
import '../../core/imgbb_service.dart';
import '../../core/user_session.dart';
import '../../core/wallet_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_icon_widget.dart';
import '../wallet_screen/wallet_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          t.profileTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: firebaseUser == null
          ? _buildNotSignedIn(context, theme, t)
          : StreamBuilder<DocumentSnapshot>(
              stream: FirestoreService.instance.userStream(firebaseUser.uid),
              builder: (context, snapshot) {
                final data = snapshot.data?.data() as Map<String, dynamic>?;
                return _ProfileBody(
                  firebaseUser: firebaseUser,
                  userData: data,
                  theme: theme,
                  t: t,
                );
              },
            ),
    );
  }

  Widget _buildNotSignedIn(BuildContext context, ThemeData theme, AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'person_outline',
            color: theme.colorScheme.outline,
            size: 56,
          ),
          SizedBox(height: 2.h),
          Text(
            t.notSignedIn,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp, fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 1.h),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.signUpLogin),
            child: Text(t.signIn, style: GoogleFonts.plusJakartaSans()),
          ),
        ],
      ),
    );
  }
}

class _ProfileBody extends StatefulWidget {
  final User firebaseUser;
  final Map<String, dynamic>? userData;
  final ThemeData theme;
  final AppLocalizations t;

  const _ProfileBody({
    required this.firebaseUser,
    required this.userData,
    required this.theme,
    required this.t,
  });

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  int _appCount    = 0;
  int _approvedCount = 0;
  double _walletBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    try {
      WalletService.instance.balanceStream().listen((bal) {
        if (mounted) setState(() => _walletBalance = bal);
      });
    } catch (_) {}
  }

  Future<void> _loadStats() async {
    try {
      final snap = await FirestoreService.instance
          .myApplicationsStream()
          .first;
      final docs = snap.docs;
      if (mounted) {
        setState(() {
          _appCount     = docs.length;
          _approvedCount = docs.where((d) =>
            (d.data() as Map<String, dynamic>)['status'] == 'approved').length;
        });
      }
    } catch (_) {}
  }

  Future<void> _signOut() async {
    await FirebaseAuthService.instance.signOut();
    await UserSession.instance.clear();
    if (mounted) context.go(AppRoutes.signUpLogin);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final theme = widget.theme;
    final user = widget.firebaseUser;
    final data = widget.userData ?? {};

    final name       = data['name'] as String? ?? user.displayName ?? 'User';
    final email      = data['email'] as String? ?? user.email ?? '';
    final phone      = data['phone'] as String? ?? user.phoneNumber ?? '';
    final photoUrl   = data['photoUrl'] as String? ?? user.photoURL ?? '';
    final kycStatus  = data['kycStatus'] as String? ?? 'pending';
    final role       = data['role'] as String? ?? UserSession.instance.role.name;

    final kycLabel = kycStatus == 'verified'
        ? t.kycVerified
        : kycStatus == 'pending'
            ? t.kycPending
            : t.kycRejected;

    final List<Map<String, dynamic>> menuItems = [
      {'key': 'edit_profile',        'icon': 'person_outline',        'label': t.editProfile},
      {'key': 'kyc',                 'icon': 'verified_user',         'label': t.kycVerification},
      {'key': 'wallet',              'icon': 'account_balance_wallet','label': t.myWallet},
      {'key': 'my_lands',            'icon': 'landscape',             'label': t.myLandListings},
      {'key': 'my_applications',     'icon': 'assignment',            'label': t.myApplications},
      {'key': 'saved_lands',         'icon': 'favorite_border',       'label': t.savedLands},
      {'key': 'reviews',             'icon': 'star_outline',          'label': t.reviewsAndRatings},
      {'key': 'notifications',       'icon': 'notifications_outlined','label': t.notifications},
      {'key': 'messages',            'icon': 'chat_bubble_outline',   'label': t.messages},
      {'key': 'help',                'icon': 'help_outline',          'label': t.helpAndSupport},
      {'key': 'settings',            'icon': 'settings',              'label': t.settings},
      {'key': 'switch_role',         'icon': 'swap_horiz',            'label': role == 'landOwner' ? t.switchToFarmer : t.switchToLandOwner},
      {'key': 'admin',               'icon': 'admin_panel_settings',  'label': t.adminPanel},
      {'key': 'logout',              'icon': 'logout',                'label': t.logout},
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Profile Header ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl.isEmpty
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: CustomIconWidget(
                          iconName: 'edit',
                          color: theme.colorScheme.onPrimary,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  email.isNotEmpty ? email : phone,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: theme.colorScheme.outline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: kycStatus == 'verified'
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: kycStatus == 'verified'
                            ? 'verified'
                            : 'hourglass_top',
                        color: kycStatus == 'verified'
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '$kycLabel · ${role == 'landOwner' ? t.landOwner : t.farmer}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kycStatus == 'verified'
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Stats ────────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                _statCard(theme, _appCount.toString(), t.applicationsStat),
                SizedBox(width: 3.w),
                _statCard(theme, _approvedCount.toString(), t.approvedStat),
                SizedBox(width: 3.w),
                _statCard(theme, '—', t.ratingStat),
              ],
            ),
          ),
          SizedBox(height: 1.5.h),
          // ── Wallet banner ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: GestureDetector(
              onTap: () => pushWalletScreen(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      const Color(0xFF1B5E20),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'account_balance_wallet',
                      color: Colors.white.withAlpha(220),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.myWallet,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.white.withAlpha(200),
                            ),
                          ),
                          Text(
                            'Rs ${_walletBalance.toStringAsFixed(2)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        t.addMoney,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // ── Menu ─────────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withAlpha(80),
                ),
              ),
              child: Column(
                children: menuItems.asMap().entries.map((entry) {
                  final index   = entry.key;
                  final item    = entry.value;
                  final isLast  = index == menuItems.length - 1;
                  final isLogout = item['key'] == 'logout';

                  return Column(
                    children: [
                      InkWell(
                        onTap: () => _handleMenuTap(context, item['key'] as String, t),
                        borderRadius: BorderRadius.only(
                          topLeft:     index == 0 ? const Radius.circular(12) : Radius.zero,
                          topRight:    index == 0 ? const Radius.circular(12) : Radius.zero,
                          bottomLeft:  isLast ? const Radius.circular(12) : Radius.zero,
                          bottomRight: isLast ? const Radius.circular(12) : Radius.zero,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: item['icon'] as String,
                                color: isLogout
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  item['label'] as String,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isLogout
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (!isLogout)
                                CustomIconWidget(
                                  iconName: 'chevron_right',
                                  color: theme.colorScheme.outline,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          color: theme.colorScheme.outlineVariant.withAlpha(60),
                          indent: 4.w,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  void _handleMenuTap(BuildContext context, String key, AppLocalizations t) {
    final data   = widget.userData ?? {};
    final role   = data['role'] as String? ?? UserSession.instance.role.name;

    switch (key) {
      case 'edit_profile':       _showEditProfileSheet(context, t);            break;
      case 'kyc':                context.push(AppRoutes.kycVerification);   break;
      case 'wallet':             pushWalletScreen(context);                  break;
      case 'my_lands':           context.go(AppRoutes.myLands);             break;
      case 'my_applications':    context.go(AppRoutes.applications);        break;
      case 'saved_lands':        context.push(AppRoutes.savedLands);        break;
      case 'reviews':            context.push(AppRoutes.reviews);           break;
      case 'notifications':      context.push(AppRoutes.notifications);     break;
      case 'messages':           context.go(AppRoutes.chat);                break;
      case 'help':               context.push(AppRoutes.helpSupport);       break;
      case 'settings':           context.push(AppRoutes.settings);          break;
      case 'switch_role':
        _showRoleSwitchDialog(
          context,
          role == 'landOwner' ? 'farmer' : 'landOwner',
          t,
        );
        break;
      case 'admin':              context.push(AppRoutes.adminPanel);        break;
      case 'logout':             _signOut();                                 break;
    }
  }

  // ── Edit Profile sheet ───────────────────────────────────────────────────

  void _showEditProfileSheet(BuildContext context, AppLocalizations t) {
    final user   = widget.firebaseUser;
    final data   = widget.userData ?? {};
    final theme  = widget.theme;

    final nameCtrl  = TextEditingController(
      text: data['name'] as String? ?? user.displayName ?? '',
    );
    final phoneCtrl = TextEditingController(
      text: data['phone'] as String? ?? user.phoneNumber ?? '',
    );
    final bioCtrl   = TextEditingController(
      text: data['bio'] as String? ?? '',
    );

    String? currentPhotoUrl = data['photoUrl'] as String? ?? user.photoURL ?? '';
    File? pickedFile;
    bool isUploadingPhoto = false;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> pickAvatar() async {
              final picker = ImagePicker();
              final picked = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 80,
                maxWidth: 600,
              );
              if (picked == null) return;
              final file = File(picked.path);
              setModalState(() {
                pickedFile = file;
                isUploadingPhoto = true;
              });
              try {
                final url = await ImgBBService.instance.uploadImage(
                  file,
                  name: 'avatar_${user.uid}_${DateTime.now().millisecondsSinceEpoch}',
                );
                setModalState(() {
                  currentPhotoUrl = url;
                  isUploadingPhoto = false;
                });
              } catch (_) {
                setModalState(() => isUploadingPhoto = false);
              }
            }

            Future<void> saveChanges() async {
              setModalState(() => isSaving = true);
              try {
                final updates = <String, dynamic>{
                  'name':  nameCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                  if (bioCtrl.text.trim().isNotEmpty)
                    'bio': bioCtrl.text.trim(),
                  if (currentPhotoUrl != null && currentPhotoUrl!.isNotEmpty)
                    'photoUrl': currentPhotoUrl,
                };
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .update(updates);
                await user.updateDisplayName(nameCtrl.text.trim());
                if (currentPhotoUrl != null && currentPhotoUrl!.isNotEmpty) {
                  await user.updatePhotoURL(currentPhotoUrl);
                }
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        t.profileUpdatedSuccessfully,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              } catch (_) {
                setModalState(() => isSaving = false);
              }
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(
                24, 16, 24,
                MediaQuery.of(ctx).viewInsets.bottom + 32,
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
                    const SizedBox(height: 16),
                    Text(
                      t.editProfile,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Avatar picker
                    Center(
                      child: GestureDetector(
                        onTap: isUploadingPhoto ? null : pickAvatar,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: theme.colorScheme.primaryContainer,
                              backgroundImage: pickedFile != null
                                  ? FileImage(pickedFile!) as ImageProvider
                                  : (currentPhotoUrl != null && currentPhotoUrl!.isNotEmpty)
                                      ? NetworkImage(currentPhotoUrl!)
                                      : null,
                              child: (pickedFile == null &&
                                      (currentPhotoUrl == null ||
                                          currentPhotoUrl!.isEmpty))
                                  ? Text(
                                      nameCtrl.text.isNotEmpty
                                          ? nameCtrl.text[0].toUpperCase()
                                          : 'U',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: theme.colorScheme.primary,
                                      ),
                                    )
                                  : null,
                            ),
                            if (isUploadingPhoto)
                              Positioned.fill(
                                child: CircleAvatar(
                                  radius: 44,
                                  backgroundColor:
                                      Colors.black.withAlpha(100),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white, width: 2,
                                  ),
                                ),
                                child: CustomIconWidget(
                                  iconName: 'camera_alt',
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Full Name
                    TextFormField(
                      controller: nameCtrl,
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: t.fullName,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: CustomIconWidget(
                            iconName: 'person_outline',
                            color: theme.colorScheme.outline,
                            size: 18,
                          ),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Phone
                    TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: t.phoneNumber,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: CustomIconWidget(
                            iconName: 'phone',
                            color: theme.colorScheme.outline,
                            size: 18,
                          ),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Bio
                    TextFormField(
                      controller: bioCtrl,
                      maxLines: 3,
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: t.bioOptional,
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: CustomIconWidget(
                            iconName: 'info_outline',
                            color: theme.colorScheme.outline,
                            size: 18,
                          ),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isSaving ? null : saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white,
                              ),
                            )
                          : Text(
                              t.saveChanges,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15, fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Role switch dialog ───────────────────────────────────────────────────

  void _showRoleSwitchDialog(BuildContext context, String targetRole, AppLocalizations t) {
    final theme = widget.theme;
    final targetLabel = targetRole == 'landOwner' ? t.landOwner : t.farmer;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '${t.switchTo} $targetLabel',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          t.switchRoleMessage.replaceFirst('यसको', targetLabel).replaceFirst('the', targetLabel),
          style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              t.cancel,
              style: GoogleFonts.plusJakartaSans(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final uid = widget.firebaseUser.uid;
                UserSession.instance.setRole(
                  targetRole == 'landOwner'
                      ? AppUserRole.landOwner
                      : AppUserRole.farmer,
                );
                await FirebaseAuthService.instance.updateUserRole(uid, targetRole);
              } catch (_) {}
              if (!mounted) return;
              if (targetRole == 'landOwner') {
                context.go(AppRoutes.myLands);
              } else {
                context.go(AppRoutes.landListings);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              t.switchLabel,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(ThemeData theme, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withAlpha(80),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: theme.colorScheme.outline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
