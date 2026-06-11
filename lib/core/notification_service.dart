import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Handles FCM push notifications — token storage, permission, foreground display.
/// 
/// SETUP REQUIRED:
/// 1. Android: The google-services.json already includes FCM config — nothing extra needed.
/// 2. iOS: Add Push Notifications capability in Xcode (if building for iOS).
/// 3. To send notifications: Use Firebase Console → Messaging, or call
///    the Admin SDK from your backend / Cloud Functions.
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _currentToken;
  String? get currentToken => _currentToken;

  // ── Initialise ────────────────────────────────────────────────────────────

  Future<void> init() async {
    // 1. Request permission (required for iOS; harmless on Android)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // 2. Get the FCM token and save it to Firestore
    await _refreshToken();

    // 3. Listen for token refreshes (device reinstall, token rotation)
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveToken);

    // 4. Handle messages when app is in FOREGROUND
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // 5. Handle notification tap when app is in BACKGROUND (but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);

    // 6. Check for initial message if app was launched from terminated state
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _onNotificationTap(initial);
  }

  Future<void> _refreshToken() async {
    final token = await _fcm.getToken();
    if (token != null) await _saveToken(token);
  }

  Future<void> _saveToken(String token) async {
    _currentToken = token;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await _db.collection('users').doc(uid).update({
        'fcmToken':         token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  // ── Foreground message handler ─────────────────────────────────────────────

  void _onForegroundMessage(RemoteMessage message) {
    // The notification is shown by the system on background/terminated.
    // In foreground we handle it here — show an in-app snack or banner.
    debugPrint(
      '[FCM] Foreground message: ${message.notification?.title} — ${message.notification?.body}',
    );
    // The app's existing notifications screen will pick this up via Firestore
    // streams if a corresponding notification doc is written alongside the push.
  }

  // ── Notification tap handler ───────────────────────────────────────────────

  void _onNotificationTap(RemoteMessage message) {
    // data payload can carry a route e.g. {"route": "/land-detail-screen", "landId": "xxx"}
    final data = message.data;
    debugPrint('[FCM] Notification tapped: $data');
    // Routing is handled by the Navigator after the widget tree is ready.
    // Store the pending route in a singleton and handle in main.dart if needed.
    _pendingRoute = data['route'] as String?;
    _pendingExtra = data['extra'] as String?;
  }

  // ── Pending deep-link route (set from terminated state) ───────────────────

  String? _pendingRoute;
  String? _pendingExtra;

  /// Call this once from your app's root navigator after init to handle
  /// any route that was triggered by a terminated-state notification tap.
  void consumePendingRoute(
    void Function(String route, String? extra) onRoute,
  ) {
    if (_pendingRoute != null) {
      onRoute(_pendingRoute!, _pendingExtra);
      _pendingRoute = null;
      _pendingExtra = null;
    }
  }

  // ── Send notification doc to Firestore (triggers cloud functions or direct FCM) ─

  /// Write a notification document to the target user's notifications subcollection.
  /// Your Firebase Cloud Function (or admin panel) should read this and send the FCM push.
  Future<void> sendInAppNotification({
    required String targetUid,
    required String title,
    required String body,
    String type = 'system',
    Map<String, dynamic>? extraData,
  }) async {
    await _db
        .collection('users')
        .doc(targetUid)
        .collection('notifications')
        .add({
      'title':     title,
      'body':      body,
      'type':      type,
      'isRead':    false,
      'createdAt': FieldValue.serverTimestamp(),
      if (extraData != null) ...extraData,
    });
  }

  // ── Subscribe to topic (admin broadcasts) ────────────────────────────────

  Future<void> subscribeToTopic(String topic) =>
      _fcm.subscribeToTopic(topic);

  Future<void> unsubscribeFromTopic(String topic) =>
      _fcm.unsubscribeFromTopic(topic);
}

// ── Background message handler (MUST be top-level function) ─────────────────

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised before this is called.
  debugPrint('[FCM] Background message: ${message.messageId}');
}
