import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_image_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding Screen — shown once on first launch
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_seen') ?? false;
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  List<_OnboardPage> _buildPages(AppLocalizations t) => [
        _OnboardPage(
          imageUrl: 'assets/Nepal_Images/nepal_indication.jpg',
          semanticLabel: 'Agricultural terraced fields in Nepal',
          icon: 'landscape',
          title: t.onb1Title,
          body: t.onb1Body,
          color: const Color(0xFF2E7D32),
        ),
        _OnboardPage(
          imageUrl: 'assets/Nepal_Images/nepal-logo-png_seeklogo-98219.png',
          semanticLabel: 'Nepal logo',
          icon: 'verified_user',
          title: t.onb2Title,
          body: t.onb2Body,
          color: const Color(0xFF1565C0),
        ),
        _OnboardPage(
          imageUrl: 'assets/Nepal_Images/nepal-beautiful-nations-flag-with-cultural-artistic-significance_1192633-74.avif',
          semanticLabel: 'Nepalese flag with cultural significance',
          icon: 'handshake',
          title: t.onb3Title,
          body: t.onb3Body,
          color: const Color(0xFF6A1B9A),
        ),
      ];

  Future<void> _next() async {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    await OnboardingScreen.markSeen();
    if (mounted) context.go(AppRoutes.initial);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final pages = _buildPages(t);
    final isLast = _currentPage == pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // ── Full-screen page view ──────────────────────────────────
            PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) =>
                  _OnboardPageWidget(page: pages[index]),
            ),

            // ── Top: Skip ─────────────────────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 20,
              child: TextButton(
                onPressed: _finish,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black.withAlpha(100),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                ),
                child: Text(
                  t.onboardingSkip,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // ── Bottom: dots + next/get started ──────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  MediaQuery.of(context).padding.bottom + 28,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(200),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dot indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(pages.length, (i) {
                        final isActive = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white
                                : Colors.white.withAlpha(100),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // CTA button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pages[_currentPage].color,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLast ? t.getStarted : t.next,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            CustomIconWidget(
                              iconName: isLast
                                  ? 'rocket_launch'
                                  : 'arrow_forward',
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Single onboarding page
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardPage {
  final String imageUrl;
  final String semanticLabel;
  final String icon;
  final String title;
  final String body;
  final Color color;

  const _OnboardPage({
    required this.imageUrl,
    required this.semanticLabel,
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });
}

class _OnboardPageWidget extends StatelessWidget {
  final _OnboardPage page;
  const _OnboardPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Full-bleed image
        CustomImageWidget(
          imageUrl: page.imageUrl,
          width: size.width,
          height: size.height,
          fit: BoxFit.cover,
          semanticLabel: page.semanticLabel,
        ),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                page.color.withAlpha(80),
                page.color.withAlpha(200),
              ],
              stops: const [0.3, 0.65, 1.0],
            ),
          ),
        ),

        // AgriPortal logo badge
        Positioned(
          top: MediaQuery.of(context).padding.top + 14,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(220),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 8,
                ),
              ],
            ),
            child: CustomImageWidget(
              imageUrl: 'assets/images/app_logo.jpeg',
              height: 32,
              fit: BoxFit.contain,
              semanticLabel: 'AgriPortal app logo',
            ),
          ),
        ),

        // Content — bottom half
        Positioned(
          left: 24,
          right: 24,
          bottom: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withAlpha(80),
                  ),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: page.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                page.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),

              // Body
              Text(
                page.body,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: Colors.white.withAlpha(220),
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
