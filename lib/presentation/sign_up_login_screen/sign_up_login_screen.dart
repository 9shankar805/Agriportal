import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_localizations.dart';
import '../../core/firebase_auth_service.dart';
import '../../core/user_session.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/splash_hero_widget.dart';

enum UserRole { farmer, landOwner }

class SignUpLoginScreen extends StatefulWidget {
  const SignUpLoginScreen({super.key});

  @override
  State<SignUpLoginScreen> createState() => _SignUpLoginScreenState();
}

class _SignUpLoginScreenState extends State<SignUpLoginScreen>
    with TickerProviderStateMixin {
  UserRole _selectedRole = UserRole.farmer;
  bool _isLoading = false;

  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _fadeCtrl.forward();
        _slideCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _setRole() {
    UserSession.instance.setRole(
      _selectedRole == UserRole.landOwner
          ? AppUserRole.landOwner
          : AppUserRole.farmer,
    );
  }

  void _navigateAfterAuth() {
    if (!mounted) return;
    _setRole();
    if (_selectedRole == UserRole.landOwner) {
      context.go(AppRoutes.myLands);
    } else {
      context.go(AppRoutes.landListings);
    }
  }

  Future<void> _onGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await FirebaseAuthService.instance.signInWithGoogle();
      if (user != null) {
        await FirebaseAuthService.instance.updateUserRole(
          user.uid,
          _selectedRole == UserRole.landOwner ? 'landOwner' : 'farmer',
        );
        _navigateAfterAuth();
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(e.toString());
      }
    }
  }

  void _onPhoneLogin() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PhoneOtpSheet(
        onConfirm: () {
          Navigator.pop(ctx);
          _navigateAfterAuth();
        },
      ),
    );
  }

  void _onSkip() => context.go(AppRoutes.landListings);

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: GoogleFonts.plusJakartaSans(fontSize: 13)),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4ED),
      body: Stack(
        children: [
          // ── Full-page scrollable content ──────────────────────────────
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                // ── Hero image ──────────────────────────────────────────
                SplashHeroWidget(height: 44.h),

                // ── Bottom card ─────────────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0F4ED),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(5.w, 3.h, 5.w, 4.h),
                        child: _buildContent(context, t),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Skip button — top right ──────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: TextButton(
              onPressed: _isLoading ? null : _onSkip,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withAlpha(200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              ),
              child: Text(
                t.browse,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations t) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Headline ──────────────────────────────────────────────────────
        Text(
          t.findYourPerfectFarmland,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A2E1A),
            height: 1.18,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          t.loginSubtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: theme.colorScheme.outline,
            height: 1.55,
          ),
        ),
        SizedBox(height: 2.5.h),

        // ── Role selector ────────────────────────────────────────────────
        Text(
          t.iWantTo,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.outline,
            letterSpacing: 0.4,
          ),
        ),
        SizedBox(height: 1.2.h),
        _RolePicker(
          selected: _selectedRole,
          onChanged: (r) => setState(() => _selectedRole = r),
        ),
        SizedBox(height: 3.h),

        // ── Auth buttons ─────────────────────────────────────────────────
        _buildGoogleButton(theme, t),
        SizedBox(height: 1.4.h),
        _buildOrDivider(theme, t),
        SizedBox(height: 1.4.h),
        _buildPhoneButton(theme, t),

        SizedBox(height: 2.5.h),

        // ── Legal ────────────────────────────────────────────────────────
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 2,
                      children: [
                        Text(
                          t.termsPrefix,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.terms),
                          child: Text(
                            t.terms,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        Text(
                          t.and,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.privacy),
                          child: Text(
                            t.privacyPolicy,
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
      ],
    );
  }

  Widget _buildGoogleButton(ThemeData theme, AppLocalizations t) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _onGoogleSignIn,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: _isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/google.png',
                    height: 22,
                    width: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    t.continueWithGoogle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A2E1A),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOrDivider(ThemeData theme, AppLocalizations t) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            t.orDivider,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: theme.colorScheme.outline,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneButton(ThemeData theme, AppLocalizations t) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onPhoneLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'smartphone',
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              t.continueWithPhone,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role picker — horizontal pill toggle
// ─────────────────────────────────────────────────────────────────────────────

class _RolePicker extends StatelessWidget {
  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  const _RolePicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          _RoleTile(
            role: UserRole.farmer,
            icon: 'agriculture',
            title: t.roleFarmer,
            subtitle: t.roleFarmerSubtitle,
            selected: selected == UserRole.farmer,
            onTap: () => onChanged(UserRole.farmer),
          ),
          const SizedBox(width: 6),
          _RoleTile(
            role: UserRole.landOwner,
            icon: 'real_estate_agent',
            title: t.roleLandOwner,
            subtitle: t.roleLandOwnerSubtitle,
            selected: selected == UserRole.landOwner,
            onTap: () => onChanged(UserRole.landOwner),
          ),
        ],
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final UserRole role;
  final String icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RoleTile({
    required this.role,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withAlpha(60),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(11),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withAlpha(40)
                          : AppTheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: icon,
                        color: selected ? Colors.white : AppTheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : const Color(0xFF1A2E1A),
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: selected
                                ? Colors.white.withAlpha(200)
                                : Theme.of(context).colorScheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// Phone OTP bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _PhoneOtpSheet extends StatefulWidget {
  final VoidCallback onConfirm;
  const _PhoneOtpSheet({required this.onConfirm});

  @override
  State<_PhoneOtpSheet> createState() => _PhoneOtpSheetState();
}

class _PhoneOtpSheetState extends State<_PhoneOtpSheet> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl   = TextEditingController();
  bool _otpSent   = false;
  bool _loading   = false;
  String? _verificationId;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_phoneCtrl.text.trim().length < 7) return;
    setState(() => _loading = true);

    await FirebaseAuthService.instance.sendOtp(
      phoneNumber: '+977${_phoneCtrl.text.trim()}',
      onAutoVerified: (PhoneAuthCredential cred) async {
        final r = await FirebaseAuth.instance.signInWithCredential(cred);
        if (r.user != null && mounted) {
          setState(() => _loading = false);
          widget.onConfirm();
        }
      },
      onVerificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.message}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13)),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      onCodeSent: (String vId, int? _) {
        if (mounted) setState(() { _loading = false; _otpSent = true; _verificationId = vId; });
      },
      onCodeAutoRetrievalTimeout: (String vId) { _verificationId = vId; },
    );
  }

  Future<void> _verifyOtp() async {
    if (_verificationId == null || _otpCtrl.text.length != 6) return;
    setState(() => _loading = true);
    try {
      final user = await FirebaseAuthService.instance.verifyOtp(
        verificationId: _verificationId!,
        smsCode: _otpCtrl.text.trim(),
      );
      if (user != null && mounted) {
        setState(() => _loading = false);
        widget.onConfirm();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(),
                style: GoogleFonts.plusJakartaSans(fontSize: 13)),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Icon
          Center(
            child: Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _otpSent ? 'message' : 'smartphone',
                  color: AppTheme.primary,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Text(
            _otpSent ? 'Enter Verification Code' : 'Phone Login',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A2E1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            _otpSent
                ? 'A 6-digit code was sent to +977 ${_phoneCtrl.text.trim()}'
                : 'Enter your Nepal phone number to receive an OTP',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: theme.colorScheme.outline,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          if (!_otpSent) ...[
            // Phone input
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4ED),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    child: Text(
                      '🇳🇵 +977',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A2E1A),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: '98XXXXXXXX',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          color: theme.colorScheme.outline,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // OTP input boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60.w,
                  child: TextField(
                    controller: _otpCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 10,
                      color: AppTheme.primary,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '······',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        letterSpacing: 10,
                        color: theme.colorScheme.outlineVariant,
                        fontWeight: FontWeight.w300,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F4ED),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppTheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _loading ? null : () => setState(() {
                  _otpSent = false;
                  _otpCtrl.clear();
                }),
                child: Text(
                  'Change number',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // CTA
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _loading ? null : (_otpSent ? _verifyOtp : _sendOtp),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white,
                      ),
                    )
                  : Text(
                      _otpSent ? 'Verify & Continue' : 'Send OTP',
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
    );
  }
}
