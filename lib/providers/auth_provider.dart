import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_model.dart';
import '../data/services/api_service.dart';
import '../core/constants/api_constants.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _api;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _user;
  bool _loading = false;
  String? _error;

  AuthProvider(this._api);

  UserModel? get user      => _user;
  bool get loading         => _loading;
  bool get authenticated   => _user != null;
  String? get error        => _error;

  // Called once at app start — restores session if Firebase user exists
  Future<void> init() async {
    if (_auth.currentUser == null) return;
    _loading = true;
    notifyListeners();
    try {
      await _syncUser();
    } catch (_) {
      // Token may be expired — force login
      await _auth.signOut();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    try {
      // 1. Create Firebase account
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // 2. Register on backend
      final data = await _api.post(ApiConstants.register, body: {
        'name': name,
        'email': email,
        if (phone != null) 'phoneNumber': phone,
      });
      _user = UserModel.fromJson(data);
      _error = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _firebaseMsg(e.code);
    } on ApiException catch (e) {
      _error = e.message;
      // Rollback Firebase user if backend failed
      await _auth.currentUser?.delete();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
    return false;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _syncUser();
      _error = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _firebaseMsg(e.code);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
    return false;
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? address,
  }) async {
    _setLoading(true);
    try {
      final data = await _api.put(ApiConstants.userProfile, body: {
        if (name    != null) 'name':        name,
        if (phone   != null) 'phoneNumber': phone,
        if (bio     != null) 'bio':         bio,
        if (address != null) 'address':     address,
      });
      _user = UserModel.fromJson(data);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _syncUser() async {
    final data = await _api.get(ApiConstants.me);
    _user = UserModel.fromJson(data);
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  String _firebaseMsg(String code) => switch (code) {
    'user-not-found'       => 'Aucun compte trouvé.',
    'wrong-password'       => 'Mot de passe incorrect.',
    'email-already-in-use' => 'Email déjà utilisé.',
    'weak-password'        => 'Mot de passe trop faible.',
    'invalid-email'        => 'Email invalide.',
    'too-many-requests'    => 'Trop de tentatives. Réessayez.',
    _                      => 'Erreur d\'authentification.',
  };
}