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

  UserModel? get user => _user;
  bool get loading => _loading;
  bool get authenticated => _user != null;
  String? get error => _error;

  /// Called once at app start — restores session if Firebase user exists.
  /// Follows the sequence diagram: Flutter → Firebase token → Backend /auth/firebase-token
  Future<void> init() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;

    _loading = true;
    notifyListeners();

    try {
      await _syncWithBackend(firebaseUser);
    } catch (e) {
      // Token invalid or user not found in backend — sign out cleanly
      await _auth.signOut();
      _user = null;
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
    String role = 'USER',
  }) async {
    _setLoading(true);
    _error = null;
    try {
      // Step 1: Create Firebase account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user!;

      // Step 2: Set display name on Firebase BEFORE getting token,
      // so backend receives it via decodedToken.getName()
      await firebaseUser.updateDisplayName(name);

      // Step 3: Send token to backend as query param — endpoint only accepts @RequestParam
      // Name/phone/role are ignored here; backend auto-creates from Firebase token data.
      // To persist the display name, update Firebase profile first so decodedToken.getName() works.
      await firebaseUser.updateDisplayName(name);
      final refreshedToken = await firebaseUser.getIdToken(true);
      if (refreshedToken == null) throw Exception('Impossible d\'obtenir le token Firebase.');

      final loginResponse = await _api.postWithQuery(
        ApiConstants.firebaseToken,
        queryParams: {'token': refreshedToken},
      );

      // Extract nested user from LoginResponse
      final userData = loginResponse['user'];
      if (userData == null) throw Exception('Réponse invalide du serveur.');
      _user = UserModel.fromJson(userData);
      _error = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _firebaseMsg(e.code);
      debugPrint('🔴 FirebaseAuthException: ${e.code} — ${e.message}');
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      debugPrint('🔴 ApiException: ${e.statusCode} — ${e.message}');
      // Rollback Firebase user if backend registration failed
      await _auth.currentUser?.delete();
      notifyListeners();
    } catch (e, stack) {
      _error = 'Une erreur inattendue est survenue.';
      debugPrint('🔴 Unknown error during register: $e');
      debugPrint('🔴 Stack: $stack');
      await _auth.currentUser?.delete();
      notifyListeners();
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
    _error = null;
    try {
      // Step 1: Authenticate with Firebase
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user!;

      // Step 2: Send Firebase token to backend (sequence diagram step 3)
      await _syncWithBackend(firebaseUser);

      _error = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _firebaseMsg(e.code);
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      _error = 'Une erreur inattendue est survenue.';
      await _auth.signOut();
      notifyListeners();
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
        if (name != null && name.isNotEmpty) 'name': name,
        if (phone != null && phone.isNotEmpty) 'phoneNumber': phone,
        if (bio != null) 'bio': bio,
        if (address != null) 'address': address,
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

  /// Follows sequence diagram steps 3-7:
  /// Flutter sends Firebase token → Backend validates with Firebase →
  /// Backend creates/retrieves user → Returns user data
  Future<void> _syncWithBackend(User firebaseUser) async {
    final idToken = await firebaseUser.getIdToken(true);
    if (idToken == null) throw Exception('Impossible d\'obtenir le token Firebase.');

    debugPrint('🔵 Syncing with backend, uid: ${firebaseUser.uid}');

    final loginResponse = await _api.postWithQuery(
      ApiConstants.firebaseToken,
      queryParams: {'token': idToken},
    );

    debugPrint('🔵 Backend response: $loginResponse');

    final userData = loginResponse['user'];
    if (userData == null) throw Exception('Réponse invalide du serveur.');
    _user = UserModel.fromJson(userData);
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  String _firebaseMsg(String code) => switch (code) {
    'user-not-found' => 'Aucun compte trouvé avec cet email.',
    'wrong-password' => 'Mot de passe incorrect.',
    'invalid-credential' => 'Email ou mot de passe incorrect.',
    'email-already-in-use' => 'Un compte existe déjà avec cet email.',
    'weak-password' => 'Mot de passe trop faible (minimum 6 caractères).',
    'invalid-email' => 'Adresse email invalide.',
    'too-many-requests' => 'Trop de tentatives. Réessayez dans quelques minutes.',
    'network-request-failed' => 'Erreur réseau. Vérifiez votre connexion.',
    _ => 'Erreur d\'authentification ($code).',
  };
}