import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/user_session.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/empty_state_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Notifications Screen — reads real data from users/{uid}/notifications
// Falls back to empty state when no notifications exist
// ─────────────────────────────────────────────────────────────────────────────

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = UserSession.instance.uid;

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
          'Notifications',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          if (uid.isNotEmpty)
            TextButton(
              onPressed: () => _markAllRead(uid),
              child: Text(
                'Mark all read',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
      body: uid.isEmpty
          ? EmptyStateWidget(
              iconName: 'notifications_none',
              title: 'Sign In Required',
              subtitle: 'Please sign in to view notifications.',
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('notifications')
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data?.docs ?? [];

                // Sort client-side newest first (no composite index needed)
                final sorted = List.of(docs)
                  ..sort((a, b) {
                    final aTs = (a.data() as Map)['createdAt'] as Timestamp?;
                    final bTs = (b.data() as Map)['createdAt'] as Timestamp?;
                    if (aTs == null && bTs == null) return 0;
                    if (aTs == null) return 1;
                    if (bTs == null) return -1;
                    return bTs.compareTo(aTs);
                  });

                if (sorted.isEmpty) {
                  return EmptyStateWidget(
                    iconName: 'notifications_none',
                    title: 'No Notifications',
                    subtitle:
                        'You are all caught up! Notifications will appear here.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color:
                        theme.colorScheme.outlineVariant.withAlpha(60),
                  ),
                  itemBuilder: (context, index) {
                    final doc = sorted[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _NotificationTile(
                      docId: doc.id,
                      uid: uid,
                      data: data,
                    );
                  },
                );
              },
            ),
    );
  }

  void _markAllRead(String uid) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get()
        .then((snap) {
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      batch.commit();
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification tile
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final String docId;
  final String uid;
  final Map<String, dynamic> data;

  const _NotificationTile({
    required this.docId,
    required this.uid,
    required this.data,
  });

  void _markRead() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(docId)
        .update({'isRead': true});
  }

  _IconSpec _iconSpec(BuildContext context) {
    final theme = Theme.of(context);
    final type = data['type'] as String? ?? 'system';
    switch (type) {
      case 'application':
        return _IconSpec(
          icon: 'assignment',
          bg: const Color(0xFFE3F2FD),
          color: const Color(0xFF1565C0),
        );
      case 'message':
        return _IconSpec(
          icon: 'chat_bubble',
          bg: theme.colorScheme.primaryContainer,
          color: theme.colorScheme.primary,
        );
      case 'land':
        return _IconSpec(
          icon: 'landscape',
          bg: const Color(0xFFE8F5E9),
          color: const Color(0xFF2E7D32),
        );
      case 'kyc':
        return _IconSpec(
          icon: 'verified_user',
          bg: const Color(0xFFFFF8E1),
          color: const Color(0xFFF57F17),
        );
      case 'wallet':
        return _IconSpec(
          icon: 'account_balance_wallet',
          bg: const Color(0xFFE8EAF6),
          color: const Color(0xFF3949AB),
        );
      default:
        return _IconSpec(
          icon: 'notifications',
          bg: const Color(0xFFF3E5F5),
          color: const Color(0xFF7B1FA2),
        );
    }
  }

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !(data['isRead'] as bool? ?? false);
    final spec = _iconSpec(context);
    final title = data['title'] as String? ?? '';
    final body = data['body'] as String? ?? '';
    final ts = data['createdAt'] as Timestamp?;

    return Dismissible(
      key: Key(docId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error.withAlpha(200),
        child: CustomIconWidget(
          iconName: 'delete',
          color: Colors.white,
          size: 22,
        ),
      ),
      onDismissed: (_) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .doc(docId)
            .delete();
      },
      child: InkWell(
        onTap: isUnread ? _markRead : null,
        child: Container(
          color: isUnread
              ? theme.colorScheme.primaryContainer.withAlpha(40)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: spec.bg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: spec.icon,
                    color: spec.color,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      body,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withAlpha(170),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _timeAgo(ts),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.w500,
                      ),
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
}

class _IconSpec {
  final String icon;
  final Color bg;
  final Color color;
  const _IconSpec({required this.icon, required this.bg, required this.color});
}
