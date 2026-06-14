import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../core/realtime_chat_service.dart';
import '../../core/user_session.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/empty_state_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Chat List Screen
// ─────────────────────────────────────────────────────────────────────────────

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Only set presence once auth is confirmed
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      RealtimeChatService.instance.setOnline();
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
        title: Text(
          'Messages',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'edit_note',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            onPressed: () {},
          ),
          SizedBox(width: 1.w),
        ],
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnap) {
          // Still waiting for auth to restore
          if (authSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final firebaseUser = authSnap.data;
          final myUid = firebaseUser?.uid ?? '';

          // Set presence now that we know auth is ready
          if (myUid.isNotEmpty) {
            RealtimeChatService.instance.setOnline();
          }

          return Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: GoogleFonts.plusJakartaSans(fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: theme.colorScheme.outline,
                    size: 18,
                  ),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
            ),
          ),

          // Conversations list — real-time from Firebase RTDB
          Expanded(
            child: myUid.isEmpty
                ? EmptyStateWidget(
                    iconName: 'chat_bubble_outline',
                    title: 'Sign in to view messages',
                    subtitle: 'Please sign in to see your conversations.',
                  )
                : StreamBuilder<List<RtConversation>>(
                    stream: RealtimeChatService.instance.myConversations(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final conversations = (snapshot.data ?? []).where((c) {
                        if (_searchQuery.isEmpty) return true;
                        final q = _searchQuery.toLowerCase();
                        return c.otherName(myUid).toLowerCase().contains(q) ||
                            c.landTitle.toLowerCase().contains(q);
                      }).toList();

                      if (conversations.isEmpty) {
                        return EmptyStateWidget(
                          iconName: 'chat_bubble_outline',
                          title: 'No Messages Yet',
                          subtitle:
                              'Start a conversation with a land owner by viewing a listing.',
                        );
                      }

                      return ListView.separated(
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        itemCount: conversations.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          indent: 4.w + 14.w + 3.w,
                          color:
                              theme.colorScheme.outlineVariant.withAlpha(80),
                        ),
                        itemBuilder: (context, index) {
                          final conv = conversations[index];
                          return _ConversationTile(
                            conversation: conv,
                            myUid: myUid,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatDetailScreen(
                                    conversation: conv,
                                    myUid: myUid,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
          );  // Column
        },  // StreamBuilder builder
      ),    // StreamBuilder
    );      // Scaffold
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Conversation Tile
// ─────────────────────────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final RtConversation conversation;
  final String myUid;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.myUid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = conversation.myUnreadCount(myUid);
    final hasUnread = unread > 0;
    final otherName = conversation.otherName(myUid);
    final otherUid = conversation.participantAId == myUid
        ? conversation.participantBId
        : conversation.participantAId;

    final lastTime = DateTime.fromMillisecondsSinceEpoch(
      conversation.lastMessageTimestamp,
    );
    final timeStr = _formatConvTime(lastTime);

    return StreamBuilder<bool>(
      stream: RealtimeChatService.instance.isUserOnline(otherUid),
      builder: (context, onlineSnap) {
        final isOnline = onlineSnap.data ?? false;
        return InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
            child: Row(
              children: [
                // Avatar with online indicator
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 7.w,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    if (isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 3.w,
                          height: 3.w,
                          decoration: BoxDecoration(
                            color: AppTheme.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              otherName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                fontWeight: hasUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            timeStr,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.sp,
                              color: hasUnread
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline,
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.4.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessage,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                color: hasUnread
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.outline,
                                fontWeight: hasUnread
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasUnread) ...[
                            SizedBox(width: 2.w),
                            Container(
                              width: 5.w,
                              height: 5.w,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$unread',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        conversation.landTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.sp,
                          color: theme.colorScheme.primary.withAlpha(180),
                          fontWeight: FontWeight.w500,
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
        );
      },
    );
  }

  String _formatConvTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return DateFormat('h:mm a').format(dt);
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat('EEE').format(dt);
    return DateFormat('MMM d').format(dt);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat Detail Screen — Real-time messages via Firebase RTDB
// ─────────────────────────────────────────────────────────────────────────────

class ChatDetailScreen extends StatefulWidget {
  final RtConversation conversation;
  final String myUid;

  const ChatDetailScreen({
    required this.conversation,
    required this.myUid,
    super.key,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showAttachOptions = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Mark conversation as read when opening
    RealtimeChatService.instance
        .markConversationRead(widget.conversation.id);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    _messageController.clear();
    try {
      await RealtimeChatService.instance.sendMessage(
        conversationId: widget.conversation.id,
        text: text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  String _formatDateHeader(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return 'Yesterday';
    }
    return DateFormat('MMM d, y').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final otherName = widget.conversation.otherName(widget.myUid);
    final otherUid = widget.conversation.participantAId == widget.myUid
        ? widget.conversation.participantBId
        : widget.conversation.participantAId;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leadingWidth: 4.w + 14.w + 8,
        leading: Row(
          children: [
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: theme.colorScheme.onSurface,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: StreamBuilder<bool>(
          stream: RealtimeChatService.instance.isUserOnline(otherUid),
          builder: (context, snap) {
            final isOnline = snap.data ?? false;
            return Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 4.5.w,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        otherName.isNotEmpty
                            ? otherName[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    if (isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 2.5.w,
                          height: 2.5.w,
                          decoration: BoxDecoration(
                            color: AppTheme.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 2.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        color: isOnline
                            ? AppTheme.success
                            : theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'call',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Land context banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            color: theme.colorScheme.primaryContainer.withAlpha(80),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'landscape',
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    widget.conversation.landTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
              ],
            ),
          ),

          // Messages — real-time stream
          Expanded(
            child: StreamBuilder<List<RtMessage>>(
              stream: RealtimeChatService.instance
                  .messagesStream(widget.conversation.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet.\nSay hello!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: theme.colorScheme.outline,
                        fontSize: 13.sp,
                      ),
                    ),
                  );
                }

                // Auto-scroll when new message arrives
                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == widget.myUid;
                    final showDateHeader = index == 0 ||
                        _formatDateHeader(
                                messages[index - 1].dateTime) !=
                            _formatDateHeader(msg.dateTime);

                    return Column(
                      children: [
                        if (showDateHeader)
                          Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: 1.h),
                            child: Text(
                              _formatDateHeader(msg.dateTime),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.sp,
                                color: theme.colorScheme.outline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        _MessageBubble(
                          message: msg,
                          isMe: isMe,
                          formatTime: _formatTime,
                          theme: theme,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Attach options panel
          if (_showAttachOptions)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              color: theme.colorScheme.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _AttachOption(
                    icon: 'camera_alt',
                    label: 'Camera',
                    onTap: () =>
                        setState(() => _showAttachOptions = false),
                  ),
                  _AttachOption(
                    icon: 'photo_library',
                    label: 'Gallery',
                    onTap: () =>
                        setState(() => _showAttachOptions = false),
                  ),
                  _AttachOption(
                    icon: 'description',
                    label: 'Document',
                    onTap: () =>
                        setState(() => _showAttachOptions = false),
                  ),
                  _AttachOption(
                    icon: 'location_on',
                    label: 'Location',
                    onTap: () =>
                        setState(() => _showAttachOptions = false),
                  ),
                ],
              ),
            ),

          // Message input bar
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 0.8,
                ),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              3.w,
              1.h,
              3.w,
              MediaQuery.of(context).viewInsets.bottom + 1.h,
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(
                        () => _showAttachOptions = !_showAttachOptions),
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: _showAttachOptions
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'attach_file',
                          color: _showAttachOptions
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.sp),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13.sp,
                          color: theme.colorScheme.outline,
                        ),
                        filled: true,
                        fillColor:
                            theme.colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: _isSending
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Center(
                              child: CustomIconWidget(
                                iconName: 'send',
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Message Bubble
// ─────────────────────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final RtMessage message;
  final bool isMe;
  final String Function(DateTime) formatTime;
  final ThemeData theme;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.formatTime,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 0.6.h,
        left: isMe ? 12.w : 0,
        right: isMe ? 0 : 12.w,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isMe
                    ? const Radius.circular(18)
                    : const Radius.circular(4),
                bottomRight: isMe
                    ? const Radius.circular(4)
                    : const Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                color: isMe ? Colors.white : theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatTime(message.dateTime),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.sp,
                  color: theme.colorScheme.outline,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                CustomIconWidget(
                  iconName: message.isRead ? 'done_all' : 'check',
                  color: message.isRead
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  size: 12,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Attach Options Row
// ─────────────────────────────────────────────────────────────────────────────

class _AttachOption extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _AttachOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.sp,
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
