import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore service for land listings, applications, and KYC.
class FirestoreService {
  static final FirestoreService instance = FirestoreService._();
  FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _myUid => _auth.currentUser?.uid;

  // ── Collections ─────────────────────────────────────────────────────────

  CollectionReference get _users        => _db.collection('users');
  CollectionReference get _lands        => _db.collection('lands');
  CollectionReference get _applications => _db.collection('applications');
  CollectionReference get _admins       => _db.collection('admins');

  // ── User ────────────────────────────────────────────────────────────────

  Stream<DocumentSnapshot> userStream(String uid) =>
      _users.doc(uid).snapshots();

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final snap = await _users.doc(uid).get();
    return snap.data() as Map<String, dynamic>?;
  }

  Future<void> updateKycStatus(String uid, String status) async {
    await _users.doc(uid).update({'kycStatus': status});
  }

  // ── Land Listings ────────────────────────────────────────────────────────

  Stream<QuerySnapshot> activeLandsStream() =>
      _lands
          .where('status', whereIn: ['active', 'approved', 'pending'])
          .snapshots();

  Stream<QuerySnapshot> myLandsStream() {
    final uid = _myUid;
    if (uid == null) return const Stream.empty();
    return _lands.where('ownerId', isEqualTo: uid).snapshots();
  }

  Future<DocumentReference> addLand(Map<String, dynamic> data) async {
    final uid = _myUid;
    if (uid == null) throw Exception('Not authenticated');
    return _lands.add({
      ...data,
      'ownerId': uid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateLand(String landId, Map<String, dynamic> data) async {
    await _lands.doc(landId).update(data);
  }

  Future<void> deleteLand(String landId) async {
    await _lands.doc(landId).delete();
  }

  // ── Applications ─────────────────────────────────────────────────────────

  /// Returns applications for the current user, sorted client-side.
  /// No composite index required — we avoid orderBy on a different field.
  Stream<QuerySnapshot> myApplicationsStream() {
    final uid = _myUid;
    if (uid == null) return const Stream.empty();
    return _applications
        .where('applicantId', isEqualTo: uid)
        .snapshots();
  }

  /// Returns applications for a specific land, sorted client-side.
  Stream<QuerySnapshot> landApplicationsStream(String landId) =>
      _applications
          .where('landId', isEqualTo: landId)
          .snapshots();

  Future<DocumentReference> applyForLand({
    required String landId,
    required String landTitle,
    required String ownerId,
    required String ownerName,
    String message = '',
  }) async {
    final uid = _myUid;
    if (uid == null) throw Exception('Not authenticated');
    final user = await getUser(uid);
    return _applications.add({
      'landId':        landId,
      'landTitle':     landTitle,
      'ownerId':       ownerId,
      'ownerName':     ownerName,
      'applicantId':   uid,
      'applicantName': user?['name'] ?? '',
      'message':       message,
      'status':        'pending',
      'appliedAt':     FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateApplicationStatus(String appId, String status) async {
    await _applications.doc(appId).update({'status': status});
    // Notify the applicant
    try {
      final appDoc = await _applications.doc(appId).get();
      final data = appDoc.data() as Map<String, dynamic>?;
      final applicantId = data?['applicantId'] as String?;
      final landTitle   = data?['landTitle']   as String? ?? 'your application';
      if (applicantId != null) {
        final msg = status == 'approved'
            ? 'Your application for "$landTitle" has been approved! Contact the owner to proceed.'
            : 'Your application for "$landTitle" was not approved this time.';
        await _users.doc(applicantId).collection('notifications').add({
          'title':     status == 'approved'
              ? 'Application Approved ✓'
              : 'Application Update',
          'body':      msg,
          'type':      'application',
          'isRead':    false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
  }

  // ── KYC Submission ───────────────────────────────────────────────────────

  Future<void> submitKyc({
    required String uid,
    required Map<String, dynamic> addressData,
    Map<String, dynamic>? documents,
    String? name,
    String? phone,
  }) async {
    await _users.doc(uid).update({
      'kycStatus':      'pending',
      'kycSubmittedAt': FieldValue.serverTimestamp(),
      'kycAddress':     addressData,
      if (documents != null) 'kycDocuments': documents,
      if (name != null && name.isNotEmpty) 'name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
  }

  // ── Admin check ──────────────────────────────────────────────────────────

  Future<bool> isAdmin(String uid) async {
    final snap = await _admins.doc(uid).get();
    return snap.exists;
  }

  // ── Admin — KYC management ────────────────────────────────────────────────

  Stream<QuerySnapshot> pendingKycStream() =>
      _users.where('kycStatus', isEqualTo: 'pending').snapshots();

  Future<void> adminSetKycStatus(String uid, String status) async {
    await _users.doc(uid).update({
      'kycStatus': status,
      'kycReviewedAt': FieldValue.serverTimestamp(),
    });
    // Write an in-app notification to the user
    final msg = status == 'verified'
        ? 'Your KYC has been verified! You can now apply for land listings.'
        : 'Your KYC was not approved. Please resubmit with clearer documents.';
    await _users.doc(uid).collection('notifications').add({
      'title':     status == 'verified' ? 'KYC Verified ✓' : 'KYC Not Approved',
      'body':      msg,
      'type':      'kyc',
      'isRead':    false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Admin — Land management ───────────────────────────────────────────────

  Stream<QuerySnapshot> pendingLandsStream() =>
      _lands.where('status', isEqualTo: 'pending').snapshots();

  Future<void> adminSetLandStatus(String landId, String status) async {
    final landDoc = await _lands.doc(landId).get();
    final data = landDoc.data() as Map<String, dynamic>?;
    final ownerId = data?['ownerId'] as String?;
    final title   = data?['title']   as String? ?? 'Your land listing';

    await _lands.doc(landId).update({
      'status': status,
      'reviewedAt': FieldValue.serverTimestamp(),
    });

    // Notify the land owner
    if (ownerId != null) {
      final msg = status == 'approved' || status == 'active'
          ? '"$title" has been approved and is now live on AgriPortal.'
          : '"$title" was not approved. Please review and resubmit.';
      await _users.doc(ownerId).collection('notifications').add({
        'title':     status == 'approved' || status == 'active'
            ? 'Land Listing Approved ✓'
            : 'Land Listing Not Approved',
        'body':      msg,
        'type':      'land',
        'isRead':    false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ── Saved Lands ───────────────────────────────────────────────────────────

  CollectionReference _savedLandsCol(String uid) =>
      _users.doc(uid).collection('savedLands');

  Stream<QuerySnapshot> savedLandsStream() {
    final uid = _myUid;
    if (uid == null) return const Stream.empty();
    return _savedLandsCol(uid).snapshots();
  }

  Future<void> saveLand(String landId, Map<String, dynamic> landData) async {
    final uid = _myUid;
    if (uid == null) throw Exception('Not authenticated');
    await _savedLandsCol(uid).doc(landId).set({
      ...landData,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unsaveLand(String landId) async {
    final uid = _myUid;
    if (uid == null) throw Exception('Not authenticated');
    await _savedLandsCol(uid).doc(landId).delete();
  }

  Future<bool> isLandSaved(String landId) async {
    final uid = _myUid;
    if (uid == null) return false;
    final snap = await _savedLandsCol(uid).doc(landId).get();
    return snap.exists;
  }

  // ── Help & Support — contact messages ────────────────────────────────────

  Future<void> sendSupportMessage({
    required String name,
    required String email,
    required String category,
    required String message,
  }) async {
    await _db.collection('supportMessages').add({
      'name':      name,
      'email':     email,
      'category':  category,
      'message':   message,
      'uid':       _myUid,
      'status':    'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
