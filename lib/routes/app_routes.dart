import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/land_details-screen/land_details-screen.dart';
import '../presentation/land_listings_screen/land_listings_screen.dart';
import '../presentation/my_lands_screen/my_lands_screen.dart';
import '../presentation/sign_up_login_screen/sign_up_login_screen.dart';
import '../presentation/applications_screen/applications_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/chat_screen/chat_screen.dart';
import '../widgets/app_scaffold.dart';
import '../presentation/kyc_verification_screen/kyc_verification_screen.dart';
import '../presentation/notifications_screen/notifications_screen.dart';
import '../presentation/saved_lands_screen/saved_lands_screen.dart';
import '../presentation/reviews_screen/reviews_screen.dart';
import '../presentation/help_support_screen/help_support_screen.dart';
import '../presentation/wallet_screen/wallet_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String signUpLogin = '/sign-up-login-screen';
  static const String landListings = '/land-listings-screen';
  static const String landDetail = '/land-detail-screen';
  static const String myLands = '/my-lands-screen';
  static const String applications = '/applications-screen';
  static const String profile = '/profile-screen';
  static const String chat = '/chat-screen';
  static const String kycVerification = '/kyc-verification-screen';
  static const String notifications = '/notifications-screen';
  static const String savedLands = '/saved-lands-screen';
  static const String reviews = '/reviews-screen';
  static const String helpSupport = '/help-support-screen';
  static const String wallet = '/wallet-screen';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.initial,
  routes: [
    // ── Auth ────────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.initial,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SignUpLoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: child,
            ),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.signUpLogin,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SignUpLoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: child,
            ),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),

    // ── Main shell (bottom nav) ──────────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppScaffold(navigationShell: navigationShell),
      branches: [
        // ── Branch 0: Explore (Farmer) ─────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.landListings,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const LandListingsScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        _slideAndFade(animation, child),
                transitionDuration: const Duration(milliseconds: 280),
              ),
              routes: [
                GoRoute(
                  path: 'detail',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: LandDetailScreen(
                      landId: state.extra as String? ?? '',
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) =>
                            _slideAndFade(animation, child),
                    transitionDuration: const Duration(milliseconds: 280),
                  ),
                ),
              ],
            ),
          ],
        ),

        // ── Branch 1: My Lands (Land Owner) ───────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.myLands,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const MyLandsScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        _slideAndFade(animation, child),
                transitionDuration: const Duration(milliseconds: 280),
              ),
            ),
          ],
        ),

        // ── Branch 2: Applications ─────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.applications,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ApplicationsScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        _slideAndFade(animation, child),
                transitionDuration: const Duration(milliseconds: 280),
              ),
            ),
          ],
        ),

        // ── Branch 3: Chat ────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.chat,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ChatScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        _slideAndFade(animation, child),
                transitionDuration: const Duration(milliseconds: 280),
              ),
            ),
          ],
        ),

        // ── Branch 4: Profile ──────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ProfileScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        _slideAndFade(animation, child),
                transitionDuration: const Duration(milliseconds: 280),
              ),
            ),
          ],
        ),
      ],
    ),

    // ── Top-level pushable routes (outside shell) ────────────────────────────
    GoRoute(
      path: AppRoutes.landDetail,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: LandDetailScreen(
          landId: state.extra as String? ?? '',
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            _slideAndFade(animation, child),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.kycVerification,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const KycVerificationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: FadeTransition(opacity: animation, child: child),
            ),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const NotificationsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            _slideAndFade(animation, child),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.savedLands,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SavedLandsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            _slideAndFade(animation, child),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.reviews,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ReviewsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            _slideAndFade(animation, child),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.helpSupport,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HelpSupportScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            _slideAndFade(animation, child),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.wallet,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const WalletScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            _slideAndFade(animation, child),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
  ],
);

// Shared slide + fade transition
Widget _slideAndFade(Animation<double> animation, Widget child) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: FadeTransition(opacity: animation, child: child),
  );
}
