import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_image_widget.dart';

class SplashHeroWidget extends StatefulWidget {
  final double height;
  const SplashHeroWidget({required this.height, super.key});

  @override
  State<SplashHeroWidget> createState() => _SplashHeroWidgetState();
}

class _SplashHeroWidgetState extends State<SplashHeroWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(scale: _scaleAnim, child: child),
      ),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              child: CustomImageWidget(
                imageUrl: 'assets/images/homescreen_logo.jpeg',
                width: double.infinity,
                height: widget.height,
                fit: BoxFit.cover,
                semanticLabel: 'AgriPortal home screen logo',
              ),
            ),
            // Gradient overlay
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppTheme.primary.withAlpha(64),
                      AppTheme.primary.withAlpha(140),
                    ],
                    stops: const [0.4, 0.75, 1.0],
                  ),
                ),
              ),
            ),
            // Logo badge top-left
            Positioned(
              top: 16,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(230),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 8),
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
            // Bottom stat strip
            Positioned(
              bottom: 16,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  _StatChip(
                    icon: 'landscape',
                    value: '2,400+',
                    label: 'Land Listings',
                  ),
                  const SizedBox(width: 10),
                  _StatChip(
                    icon: 'verified_user',
                    value: '1,800+',
                    label: 'Verified Farmers',
                  ),
                  const SizedBox(width: 10),
                  _StatChip(
                    icon: 'handshake',
                    value: '950+',
                    label: 'Agreements',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(217),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.black.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }
}
