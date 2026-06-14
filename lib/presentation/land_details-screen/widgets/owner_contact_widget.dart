import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_export.dart';
import '../../../core/app_localizations.dart';
import '../../../core/firestore_service.dart';
import '../../../core/realtime_chat_service.dart';
import '../../../core/user_session.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../chat_screen/chat_screen.dart';
import '../../land_listings_screen/land_listings_screen.dart';

class OwnerContactWidget extends StatefulWidget {
  final LandModel land;
  // true once farmer's application is approved — reveals full contact
  final bool isContactRevealed;
  final String ownerId;

  const OwnerContactWidget({
    required this.land,
    this.isContactRevealed = false,
    required this.ownerId,
    super.key,
  });

  @override
  State<OwnerContactWidget> createState() => _OwnerContactWidgetState();
}

class _OwnerContactWidgetState extends State<OwnerContactWidget> {
  bool _loadingChat = false;

  /// Opens a conversation with the land owner.
  /// Checks KYC first, then creates / retrieves the RTDB conversation,
  /// then pushes straight into ChatDetailScreen.
  Future<void> _openChat() async {
    final myUid = UserSession.instance.uid;
    if (myUid.isEmpty) {
      context.push(AppRoutes.signUpLogin);
      return;
    }

    // Prevent chatting with yourself (land owner viewing their own listing)
    if (myUid == widget.ownerId) return;

    // KYC gate — same pattern as the apply flow
    final userData = await FirestoreService.instance.getUser(myUid);
    final kycStatus = userData?['kycStatus'] as String? ?? 'pending';

    if (!mounted) return;

    if (kycStatus != 'verified') {
      final isNotStarted = kycStatus != 'pending';
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            'KYC Verification Required',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          content: Text(
            isNotStarted
                ? 'You need to complete KYC verification before messaging a land owner. Tap below to start.'
                : 'Your KYC is under review. You can message owners once our admin team approves your documents (1–2 business days).',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (isNotStarted)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.kycVerification);
                },
                child: const Text('Verify KYC'),
              ),
          ],
        ),
      );
      return;
    }

    setState(() => _loadingChat = true);
    try {
      final convId = await RealtimeChatService.instance.getOrCreateConversation(
        otherUid:   widget.ownerId,
        otherName:  widget.land.ownerName,
        landId:     widget.land.id,
        landTitle:  widget.land.title,
      );

      // Build a minimal RtConversation so ChatDetailScreen can render immediately
      // without waiting for another RTDB fetch.
      final myIds = [myUid, widget.ownerId]..sort();
      final conv = RtConversation(
        id:                    convId,
        participantAId:        myIds[0],
        participantBId:        myIds[1],
        participantAName:      myIds[0] == myUid
            ? (UserSession.instance.displayName)
            : widget.land.ownerName,
        participantBName:      myIds[0] == myUid
            ? widget.land.ownerName
            : (UserSession.instance.displayName),
        landId:                widget.land.id,
        landTitle:             widget.land.title,
        lastMessage:           '',
        lastMessageTimestamp:  DateTime.now().millisecondsSinceEpoch,
        unreadCountA:          0,
        unreadCountB:          0,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              conversation: conv,
              myUid: myUid,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open chat: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Show first name only before approval; full name after
    final displayName = widget.isContactRevealed
        ? widget.land.ownerName
        : '${widget.land.ownerName.split(' ').first} ••••';

    final initial = widget.land.ownerName.isNotEmpty
        ? widget.land.ownerName[0].toUpperCase()
        : 'O';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          // ── Owner avatar — initials (no hardcoded URL) ─────────────────
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primaryContainer,
                child: Text(
                  initial,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              if (widget.land.isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 8,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // ── Owner info ────────────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.publicProfile, extra: widget.ownerId),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'star',
                        color: const Color(0xFFF9A825),
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          widget.land.ownerRating > 0
                              ? '${widget.land.ownerRating.toStringAsFixed(1)} · ${t.landOwner}'
                              : t.landOwner,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: theme.colorScheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Message button ────────────────────────────────────────────
          GestureDetector(
            onTap: _loadingChat ? null : _openChat,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: _loadingChat
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primary,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'chat_bubble_outline',
                          color: AppTheme.primary,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.isContactRevealed ? t.message : t.chat,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
