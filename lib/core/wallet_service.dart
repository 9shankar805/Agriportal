import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Model for a single wallet transaction entry.
class WalletTransaction {
  final String id;
  final double amount;
  final String type;       // 'credit' | 'debit'
  final String description;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  bool get isCredit => type == 'credit';

  factory WalletTransaction.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return WalletTransaction(
      id:          doc.id,
      amount:      (d['amount'] as num? ?? 0).toDouble(),
      type:        d['type'] as String? ?? 'credit',
      description: d['description'] as String? ?? '',
      createdAt:   (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Wallet service — stores each user's balance in
/// `users/{uid}/wallet/balance` (a single doc) and
/// transactions in `users/{uid}/walletTransactions`.
class WalletService {
  static final WalletService instance = WalletService._();
  WalletService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Minimum balance required to list a land (in NPR).
  static const double listingFee = 20.0;

  String? get _uid => _auth.currentUser?.uid;

  // ── Internal helpers ─────────────────────────────────────────────────────

  DocumentReference get _walletDoc {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    return _db.collection('users').doc(uid).collection('wallet').doc('balance');
  }

  CollectionReference get _txCol {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    return _db.collection('users').doc(uid).collection('walletTransactions');
  }

  /// Ensures the wallet document exists with a 0.0 balance.
  Future<void> _ensureWalletExists() async {
    final snap = await _walletDoc.get();
    if (!snap.exists) {
      await _walletDoc.set({'balance': 0.0, 'updatedAt': FieldValue.serverTimestamp()});
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Real-time stream of the wallet balance.
  Stream<double> balanceStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _walletDoc.snapshots().map((snap) {
      if (!snap.exists) return 0.0;
      final data = snap.data() as Map<String, dynamic>?;
      return (data?['balance'] as num? ?? 0).toDouble();
    });
  }

  /// Fetch balance once.
  Future<double> getBalance() async {
    await _ensureWalletExists();
    final snap = await _walletDoc.get();
    final data = snap.data() as Map<String, dynamic>?;
    return (data?['balance'] as num? ?? 0).toDouble();
  }

  /// Real-time stream of the 20 most recent transactions.
  Stream<List<WalletTransaction>> transactionsStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _txCol
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) =>
            snap.docs.map(WalletTransaction.fromFirestore).toList());
  }

  /// Add money to the wallet (credit).
  Future<void> addMoney(double amount, {String description = 'Added to wallet'}) async {
    if (amount <= 0) throw Exception('Amount must be greater than 0');
    await _ensureWalletExists();

    await _db.runTransaction((tx) async {
      final snap = await tx.get(_walletDoc);
      final current = (snap.data() as Map<String, dynamic>?)?['balance'] as num? ?? 0;
      final newBalance = current.toDouble() + amount;

      tx.update(_walletDoc, {
        'balance':   newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.set(_txCol.doc(), {
        'amount':      amount,
        'type':        'credit',
        'description': description,
        'createdAt':   FieldValue.serverTimestamp(),
      });
    });
  }

  /// Deduct the listing fee (debit). Throws if balance is insufficient.
  Future<void> chargeListingFee({String landTitle = 'Land listing'}) async {
    await _ensureWalletExists();

    await _db.runTransaction((tx) async {
      final snap = await tx.get(_walletDoc);
      final current = (snap.data() as Map<String, dynamic>?)?['balance'] as num? ?? 0;
      final balance = current.toDouble();

      if (balance < listingFee) {
        throw Exception(
          'Insufficient balance. You need at least Rs ${listingFee.toStringAsFixed(0)} to list a land.',
        );
      }

      tx.update(_walletDoc, {
        'balance':   balance - listingFee,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.set(_txCol.doc(), {
        'amount':      listingFee,
        'type':        'debit',
        'description': 'Listing fee — $landTitle',
        'createdAt':   FieldValue.serverTimestamp(),
      });
    });
  }
}
