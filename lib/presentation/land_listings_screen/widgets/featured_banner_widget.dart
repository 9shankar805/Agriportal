import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';

class FeaturedBannerWidget extends StatefulWidget {
  final VoidCallback onExploreTap;
  const FeaturedBannerWidget({required this.onExploreTap, super.key});

  @override
  State<FeaturedBannerWidget> createState() => _FeaturedBannerWidgetState();
}

class _FeaturedBannerWidgetState extends State<FeaturedBannerWidget> {
  // TODO: Replace with [Riverpod/Bloc] for production
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<Map<String, String>> _banners = [
    {
      'imageUrl':
          'https://images.pexels.com/photos/974314/pexels-photo-974314.jpeg',
      'semanticLabel':
          'Aerial view of lush terraced agricultural fields in Nepal with farmers working',
      'headline': 'Fertile. Verified. Yours.',
      'subtitle':
          'Discover certified agricultural land across Nepal\'s provinces',
    },
    {
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_19497ddc5-1780739454375.png',
      'semanticLabel':
          'Green vegetable farm plots with irrigation system in Terai plains Nepal',
      'headline': 'Start Farming Today.',
      'subtitle':
          'KYC-verified farmers get priority access to premium listings',
    },
    {
      'imageUrl':
          'https://images.pexels.com/photos/1581484/pexels-photo-1581484.jpeg',
      'semanticLabel': 'Rolling tea garden hills with mist in Ilam Nepal',
      'headline': 'Premium Tea Gardens.',
      'subtitle': 'Ilam\'s finest tea garden leases — limited availability',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 214,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _banners.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final banner = _banners[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomImageWidget(
                        imageUrl: banner['imageUrl']!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        semanticLabel: banner['semanticLabel']!,
                      ),
                      // Dark gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.black.withOpacity(0.04),
                              Colors.black.withOpacity(0.72),
                            ],
                            stops: const [0.25, 1.0],
                          ),
                        ),
                      ),
                      // Content overlay
                      Positioned(
                        left: 16,
                        bottom: 16,
                        right: 90,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              banner['headline']!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner['subtitle']!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withAlpha(217),
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // CTA button
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: ElevatedButton(
                          onPressed: widget.onExploreTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Explore',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Demo Video pill
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(140),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'play_circle_outline',
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Virtual Tour',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
              // Dot indicators
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_banners.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentPage == i ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? Colors.white
                            : Colors.white.withAlpha(102),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
