import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppUserRole { farmer, landOwner }

/// Lightweight session store — persists role to SharedPreferences
/// and exposes the Firebase Auth current user.
class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  static const _roleKey = 'user_role';

  AppUserRole _role = AppUserRole.farmer;

  AppUserRole get role => _role;
  bool get isLandOwner => _role == AppUserRole.landOwner;
  bool get isFarmer => _role == AppUserRole.farmer;

  /// Currently signed-in Firebase user (null if not signed in).
  User? get firebaseUser => FirebaseAuth.instance.currentUser;
  bool get isSignedIn => firebaseUser != null;

  String get uid => firebaseUser?.uid ?? '';
  String get displayName =>
      firebaseUser?.displayName ??
      firebaseUser?.phoneNumber ??
      'User';

  void setRole(AppUserRole role) {
    _role = role;
    _persistRole(role);
  }

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_roleKey);
    if (saved == 'landOwner') {
      _role = AppUserRole.landOwner;
    } else {
      _role = AppUserRole.farmer;
    }
  }

  Future<void> _persistRole(AppUserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _roleKey,
      role == AppUserRole.landOwner ? 'landOwner' : 'farmer',
    );
  }

  Future<void> clear() async {
    _role = AppUserRole.farmer;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
  }
}
