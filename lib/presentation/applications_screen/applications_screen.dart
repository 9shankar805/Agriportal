import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/firestore_service.dart';
import '../../core/user_session.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_skeleton_widget.dart';

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = UserSession.instance.uid;

    if (uid.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _appBar(theme),
        body: EmptyStateWidget(
          iconName: 'assignment_outlined',
          title: 'Sign In Required',
          subtitle: 'Please sign in to view your applications.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _appBar(theme),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.instance.myApplicationsStream(),
        builder: (context, snapshot) {
          // ── Loading ────────────────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => LoadingSkeletonWidget(
                width: double.infinity,
                height: 90,
                borderRadius: 12,
              ),
            );
          }

          // ── Error ──────────────────────────────────────────────────────
          if (snapshot.hasError) {
            final err = snapshot.error.toString();
            // Firestore index missing — common error
            final isIndexError = err.contains('index') ||
                err.contains('FAILED_PRECONDITION') ||
                err.contains('requires an index');
            // Security rules denial
            final isPermissionError =
                err.contains('PERMISSION_DENIED') ||
                err.contains('permission-denied');

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: isPermissionError
                              ? 'lock_outline'
                              : 'cloud_off',
                          color: theme.colorScheme.error,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPermissionError
                          ? 'Access Denied'
                          : isIndexError
                              ? 'Setup Required'
                              : 'Could Not Load',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPermissionError
                          ? 'Your Firestore security rules are blocking this query.\n\nMake sure your rules allow reading applications where applicantId == your uid.'
                          : isIndexError
                              ? 'A Firestore composite index is required.\n\nGo to Firebase Console → Firestore → Indexes and create a composite index on the "applications" collection for fields:\n• applicantId (Ascending)\n• appliedAt (Descending)'
                              : 'Something went wrong.\n\n$err',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: theme.colorScheme.outline,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Data ───────────────────────────────────────────────────────
          final docs = snapshot.data?.docs ?? [];

          // Sort client-side by appliedAt descending (no composite index needed)
          final sorted = List.of(docs)..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTs = aData['appliedAt'] as Timestamp?;
            final bTs = bData['appliedAt'] as Timestamp?;
            if (aTs == null && bTs == null) return 0;
            if (aTs == null) return 1;
            if (bTs == null) return -1;
            return bTs.compareTo(aTs);
          });

          if (sorted.isEmpty) {
            return _buildEmptyState(context, theme);
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = sorted[index].data() as Map<String, dynamic>;
              return _buildApplicationCard(context, theme, data);
            },
          );
        },
      ),
    );
  }

  AppBar _appBar(ThemeData theme) => AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'My Applications',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      );

  Widget _buildApplicationCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> app,
  ) {
    final status = (app['status'] as String? ?? 'pending').toLowerCase();
    final Color statusColor = status == 'approved'
        ? const Color(0xFF388E3C)
        : status == 'rejected'
            ? const Color(0xFFC62828)
            : const Color(0xFFF57F17);
    final String statusLabel = status[0].toUpperCase() + status.substring(1);

    final appliedAt = app['appliedAt'];
    String dateStr = '';
    if (appliedAt is Timestamp) {
      final dt = appliedAt.toDate();
      dateStr = '${dt.day} ${_monthName(dt.month)}, ${dt.year}';
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(80),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Land icon placeholder ──────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
            child: Container(
              width: 90,
              height: 100,
              color: theme.colorScheme.primaryContainer,
              child: Center(
                child: CustomIconWidget(
                  iconName: 'landscape',
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
              ),
            ),
          ),
          // ── Info ──────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    app['landTitle'] as String? ?? 'Unknown Land',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Owner
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'person_outline',
                        color: theme.colorScheme.outline,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          app['ownerName'] as String? ?? '—',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: theme.colorScheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Status + date row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (dateStr.isNotEmpty)
                        Text(
                          dateStr,
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
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
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'assignment_outlined',
                  color: theme.colorScheme.primary,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Applications Yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse available lands and submit\nyour first application.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: theme.colorScheme.outline,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][m];
}
