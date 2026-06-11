import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Model classes for chat

class RtMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final int timestamp;
  final bool isRead;

  const RtMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isRead,
  });

  factory RtMessage.fromSnapshot(DataSnapshot snap) {
    final data = Map<String, dynamic>.from(snap.value as Map);
    return RtMessage(
      id: snap.key ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? 0,
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'timestamp': timestamp,
        'isRead': isRead,
      };

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp);
}

class RtConversation {
  final String id;
  final String participantAId;
  final String participantBId;
  final String participantAName;
  final String participantBName;
  final String landId;
  final String landTitle;
  final String lastMessage;
  final int lastMessageTimestamp;
  final int unreadCountA;
  final int unreadCountB;

  const RtConversation({
    required this.id,
    required this.participantAId,
    required this.participantBId,
    required this.participantAName,
    required this.participantBName,
    required this.landId,
    required this.landTitle,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.unreadCountA,
    required this.unreadCountB,
  });

  factory RtConversation.fromSnapshot(DataSnapshot snap) {
    final data = Map<String, dynamic>.from(snap.value as Map);
    return RtConversation(
      id: snap.key ?? '',
      participantAId: data['participantAId'] ?? '',
      participantBId: data['participantBId'] ?? '',
      participantAName: data['participantAName'] ?? '',
      participantBName: data['participantBName'] ?? '',
      landId: data['landId'] ?? '',
      landTitle: data['landTitle'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTimestamp: data['lastMessageTimestamp'] ?? 0,
      unreadCountA: data['unreadCountA'] ?? 0,
      unreadCountB: data['unreadCountB'] ?? 0,
    );
  }

  /// Returns the other participant's name from the current user's perspective.
  String otherName(String myUid) =>
      participantAId == myUid ? participantBName : participantAName;

  /// Returns the unread count for the current user.
  int myUnreadCount(String myUid) =>
      participantAId == myUid ? unreadCountA : unreadCountB;
}

/// Service that reads/writes to Firebase Realtime Database for chat.
/// 
/// RTDB Structure:
/// /conversations/{conversationId}/
///     participantAId, participantBId, ...metadata...
/// /messages/{conversationId}/{messageId}/
///     senderId, senderName, text, timestamp, isRead
class RealtimeChatService {
  static final RealtimeChatService instance = RealtimeChatService._();
  RealtimeChatService._();

  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _myUid => _auth.currentUser?.uid;
  String get _myName =>
      _auth.currentUser?.displayName ??
      _auth.currentUser?.phoneNumber ??
      'User';

  // ── Conversations ───────────────────────────────────────────────────────

  /// Stream of all conversations involving the current user.
  Stream<List<RtConversation>> myConversations() {
    final uid = _myUid;
    if (uid == null) return const Stream.empty();

    // Listen to all conversations — filter on the client side.
    // For large apps, use server-side indexes. This is fine for MVP.
    return _db.ref('conversations').onValue.map((event) {
      final snap = event.snapshot;
      if (!snap.exists || snap.value == null) return <RtConversation>[];
      final map = Map<String, dynamic>.from(snap.value as Map);
      return map.entries
          .map((e) => RtConversation.fromSnapshot(
              snap.child(e.key)))
          .where((c) =>
              c.participantAId == uid || c.participantBId == uid)
          .toList()
        ..sort((a, b) =>
            b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));
    });
  }

  /// Create a new conversation or return the existing ID.
  Future<String> getOrCreateConversation({
    required String otherUid,
    required String otherName,
    required String landId,
    required String landTitle,
  }) async {
    final uid = _myUid;
    if (uid == null) throw Exception('Not authenticated');

    // Deterministic conversation ID so duplicates are avoided.
    final ids = [uid, otherUid]..sort();
    final convId = '${ids[0]}_${ids[1]}_$landId';

    final ref = _db.ref('conversations/$convId');
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'participantAId': ids[0],
        'participantBId': ids[1],
        'participantAName': ids[0] == uid ? _myName : otherName,
        'participantBName': ids[0] == uid ? otherName : _myName,
        'landId': landId,
        'landTitle': landTitle,
        'lastMessage': '',
        'lastMessageTimestamp': ServerValue.timestamp,
        'unreadCountA': 0,
        'unreadCountB': 0,
      });
    }
    return convId;
  }

  // ── Messages ────────────────────────────────────────────────────────────

  /// Real-time stream of messages in a conversation.
  Stream<List<RtMessage>> messagesStream(String conversationId) {
    return _db
        .ref('messages/$conversationId')
        .orderByChild('timestamp')
        .onValue
        .map((event) {
      final snap = event.snapshot;
      if (!snap.exists || snap.value == null) return <RtMessage>[];
      final map = Map<String, dynamic>.from(snap.value as Map);
      return map.entries
          .map((e) => RtMessage.fromSnapshot(snap.child(e.key)))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }

  /// Send a message to a conversation.
  Future<void> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    final uid = _myUid;
    if (uid == null) throw Exception('Not authenticated');

    final msgRef = _db.ref('messages/$conversationId').push();
    final now = ServerValue.timestamp;

    await msgRef.set({
      'senderId': uid,
      'senderName': _myName,
      'text': text,
      'timestamp': now,
      'isRead': false,
    });

    // Update conversation metadata
    await _db.ref('conversations/$conversationId').update({
      'lastMessage': text,
      'lastMessageTimestamp': now,
    });

    // Increment unread for the OTHER participant
    final convSnap =
        await _db.ref('conversations/$conversationId').get();
    if (convSnap.exists) {
      final conv = RtConversation.fromSnapshot(convSnap);
      if (conv.participantAId == uid) {
        await _db
            .ref('conversations/$conversationId/unreadCountB')
            .set(ServerValue.increment(1));
      } else {
        await _db
            .ref('conversations/$conversationId/unreadCountA')
            .set(ServerValue.increment(1));
      }
    }
  }

  /// Mark all messages in a conversation as read for the current user.
  Future<void> markConversationRead(String conversationId) async {
    final uid = _myUid;
    if (uid == null) return;

    final convSnap =
        await _db.ref('conversations/$conversationId').get();
    if (!convSnap.exists) return;
    final conv = RtConversation.fromSnapshot(convSnap);

    if (conv.participantAId == uid) {
      await _db
          .ref('conversations/$conversationId/unreadCountA')
          .set(0);
    } else {
      await _db
          .ref('conversations/$conversationId/unreadCountB')
          .set(0);
    }

    // Mark individual messages as read
    final msgsSnap =
        await _db.ref('messages/$conversationId').get();
    if (!msgsSnap.exists || msgsSnap.value == null) return;
    final map = Map<String, dynamic>.from(msgsSnap.value as Map);
    for (final key in map.keys) {
      final msgData =
          Map<String, dynamic>.from(map[key] as Map);
      if (msgData['senderId'] != uid && msgData['isRead'] == false) {
        await _db
            .ref('messages/$conversationId/$key/isRead')
            .set(true);
      }
    }
  }

  // ── Presence ────────────────────────────────────────────────────────────

  void setOnline() {
    final uid = _myUid;
    if (uid == null) return;
    final presenceRef = _db.ref('presence/$uid');
    presenceRef.set({'online': true, 'lastSeen': ServerValue.timestamp});
    presenceRef.onDisconnect().set({
      'online': false,
      'lastSeen': ServerValue.timestamp,
    });
  }

  Stream<bool> isUserOnline(String uid) {
    return _db.ref('presence/$uid/online').onValue.map(
          (event) => event.snapshot.value == true,
        );
  }
}
