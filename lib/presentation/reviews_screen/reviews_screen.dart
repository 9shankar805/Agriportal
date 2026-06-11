import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/user_session.dart';
import '../../theme/app_theme.dart';import '../../widgets/custom_icon_widget.dart';
import '../../widgets/empty_state_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

class UserReview {
  final String id;
  final String reviewerName;
  final String reviewerAvatarUrl;
  final String reviewerRole;
  final double rating;
  final String comment;
  final String date;
  final String? landTitle;

  const UserReview({
    required this.id,
    required this.reviewerName,
    required this.reviewerAvatarUrl,
    required this.reviewerRole,
    required this.rating,
    required this.comment,
    required this.date,
    this.landTitle,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Seed data
// ─────────────────────────────────────────────────────────────────────────────

final List<UserReview> _seedReviews = [
  const UserReview(
    id: 'r1',
    reviewerName: 'Ramesh Thapa',
    reviewerAvatarUrl:
        'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg',
    reviewerRole: 'Land Owner',
    rating: 5.0,
    comment:
        'Excellent farmer! Very responsible, paid rent on time and took great care of the land. Would lease to him again.',
    date: 'Jun 5, 2026',
    landTitle: 'Fertile Paddy Fields — Chitwan',
  ),
  const UserReview(
    id: 'r2',
    reviewerName: 'Sita Maharjan',
    reviewerAvatarUrl:
        'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg',
    reviewerRole: 'Land Owner',
    rating: 4.5,
    comment:
        'Good communication throughout. Left the land in better condition than he found it. Recommended.',
    date: 'May 20, 2026',
    landTitle: 'Vegetable Garden Plot — Kavre',
  ),
  const UserReview(
    id: 'r3',
    reviewerName: 'Dorje Gurung',
    reviewerAvatarUrl:
        'https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg',
    reviewerRole: 'Land Owner',
    rating: 4.0,
    comment:
        'Knowledgeable about orchard farming. Some delays in the first month but overall a trustworthy tenant.',
    date: 'May 10, 2026',
    landTitle: 'Apple Orchard Land — Mustang',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  bool _showWriteReview = false;
  bool _isSubmittingReview = false;
  int _newRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  // Live reviews — starts with seed, replaced by Firestore
  List<UserReview> _reviews = List.from(_seedReviews);

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    final uid = UserSession.instance.uid;
    if (uid.isEmpty) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();
      if (snap.docs.isEmpty || !mounted) return;
      setState(() {
        _reviews = snap.docs.map((d) {
          final v = d.data();
          return UserReview(
            id:               d.id,
            reviewerName:     v['reviewerName']    as String? ?? '',
            reviewerAvatarUrl: v['reviewerAvatar'] as String? ?? '',
            reviewerRole:     v['reviewerRole']    as String? ?? '',
            rating:           (v['rating']         as num? ?? 0).toDouble(),
            comment:          v['comment']         as String? ?? '',
            date: v['createdAt'] is Timestamp
                ? _fmtDate((v['createdAt'] as Timestamp).toDate())
                : '',
            landTitle:        v['landTitle']       as String?,
          );
        }).toList();
      });
    } catch (_) {}
  }

  String _fmtDate(DateTime d) {
    const m = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month]} ${d.day}, ${d.year}';
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;
  }

  Map<int, int> get _ratingBreakdown {
    final map = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in _reviews) { map[r.rating.round()] = (map[r.rating.round()] ?? 0) + 1; }
    return map;
  }

  Future<void> _submitReview() async {
    if (_newRating == 0 || _reviewController.text.length < 10) return;
    setState(() => _isSubmittingReview = true);
    final uid = UserSession.instance.uid;
    final name = UserSession.instance.displayName;
    try {
      if (uid.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users').doc(uid)
            .collection('reviews')
            .add({
          'reviewerName':  name,
          'reviewerAvatar': '',
          'reviewerRole':  UserSession.instance.role == AppUserRole.landOwner ? 'Land Owner' : 'Farmer',
          'rating':        _newRating.toDouble(),
          'comment':       _reviewController.text.trim(),
          'createdAt':     FieldValue.serverTimestamp(),
          'landTitle':     null,
        });
      }
      // Add locally for immediate feedback
      setState(() {
        _reviews.insert(0, UserReview(
          id:               DateTime.now().toIso8601String(),
          reviewerName:     name,
          reviewerAvatarUrl: '',
          reviewerRole:     UserSession.instance.role == AppUserRole.landOwner ? 'Land Owner' : 'Farmer',
          rating:           _newRating.toDouble(),
          comment:          _reviewController.text.trim(),
          date:             _fmtDate(DateTime.now()),
        ));
        _showWriteReview = false;
        _newRating = 0;
        _reviewController.clear();
        _isSubmittingReview = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Review submitted!', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
          backgroundColor: AppTheme.success, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      setState(() => _isSubmittingReview = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 22,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Reviews & Ratings',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating summary card
            _buildRatingSummary(theme),
            SizedBox(height: 2.5.h),

            // Write review button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    setState(() => _showWriteReview = !_showWriteReview),
                icon: CustomIconWidget(
                  iconName: _showWriteReview ? 'close' : 'rate_review',
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                label: Text(
                  _showWriteReview ? 'Cancel' : 'Write a Review',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Write review form
            if (_showWriteReview) ...[
              SizedBox(height: 2.h),
              _buildWriteReviewForm(theme),
            ],

            SizedBox(height: 2.5.h),

            // Reviews list
            Text(
              'All Reviews (${_reviews.length})',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.5.h),

            if (_reviews.isEmpty)
              EmptyStateWidget(
                iconName: 'star_outline',
                title: 'No Reviews Yet',
                subtitle: 'Be the first to leave a review after your lease experience.',
              )
            else
              ...List.generate(_reviews.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 1.5.h),
                  child: _ReviewCard(review: _reviews[index]),
                );
              }),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummary(ThemeData theme) {
    final avg = _averageRating;
    final breakdown = _ratingBreakdown;
    final total = _reviews.length;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Big average score
          Column(
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                  height: 1,
                ),
              ),
              _StarRow(rating: avg, size: 14),
              SizedBox(height: 0.5.h),
              Text(
                '$total reviews',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.sp,
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          SizedBox(width: 4.w),

          // Breakdown bars
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = breakdown[star] ?? 0;
                final fraction = total > 0 ? count / total : 0.0;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.4.h),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.sp,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      CustomIconWidget(
                        iconName: 'star',
                        color: AppTheme.accent,
                        size: 12,
                      ),
                      SizedBox(width: 1.5.w),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fraction,
                            backgroundColor:
                                theme.colorScheme.outlineVariant.withAlpha(100),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primary,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      SizedBox(width: 1.5.w),
                      SizedBox(
                        width: 3.w,
                        child: Text(
                          '$count',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.sp,
                            color: theme.colorScheme.outline,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWriteReviewForm(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Rating',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.outline,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () => setState(() => _newRating = i + 1),
                child: Padding(
                  padding: EdgeInsets.only(right: 1.w),
                  child: CustomIconWidget(
                    iconName:
                        i < _newRating ? 'star' : 'star_outline',
                    color: i < _newRating
                        ? AppTheme.accent
                        : theme.colorScheme.outlineVariant,
                    size: 28,
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 1.5.h),
          TextFormField(
            controller: _reviewController,
            maxLines: 4,
            style: GoogleFonts.plusJakartaSans(fontSize: 13.sp),
            decoration: InputDecoration(
              hintText:
                  'Share your experience with this land owner or farmer...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                color: theme.colorScheme.outline,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.5.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _newRating > 0 && _reviewController.text.length >= 10
                  ? (_isSubmittingReview ? null : _submitReview)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                disabledBackgroundColor: theme.colorScheme.outlineVariant.withAlpha(100),
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isSubmittingReview
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Submit Review',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Review Card
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final UserReview review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 5.w,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: NetworkImage(review.reviewerAvatarUrl),
                onBackgroundImageError: (_, __) {},
              ),
              SizedBox(width: 2.5.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      review.reviewerRole,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StarRow(rating: review.rating, size: 12),
                  SizedBox(height: 0.3.h),
                  Text(
                    review.date,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.sp,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (review.landTitle != null) ...[
            SizedBox(height: 1.h),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(80),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'landscape',
                    color: theme.colorScheme.primary,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    review.landTitle!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.sp,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 1.h),
          Text(
            review.comment,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: theme.colorScheme.onSurface.withAlpha(190),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Star Row
// ─────────────────────────────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  final double rating;
  final double size;

  const _StarRow({required this.rating, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        IconData icon;
        if (i < rating.floor()) {
          icon = Icons.star_rounded;
        } else if (i < rating) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        return Icon(icon, color: AppTheme.accent, size: size);
      }),
    );
  }
}
