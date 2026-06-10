import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

/// Firebase Authentication Service
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  late FirebaseAuth _auth;
  late GoogleSignIn _googleSignIn;
  final Logger _logger = Logger();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal() {
    _auth = FirebaseAuth.instance;
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'profile',
      ],
    );
  }

  /// Initialize Firebase
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _logger.i('Firebase initialized successfully');
    } catch (e) {
      _logger.e('Error initializing Firebase: $e');
      rethrow;
    }
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get current user's ID token
  Future<String?> getIdToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } catch (e) {
      _logger.e('Error getting ID token: $e');
      return null;
    }
  }

  // ============================================================================
  // GOOGLE SIGN-IN
  // ============================================================================

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Sign out previous session
      await _googleSignIn.signOut();

      // Trigger Google Sign-In
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _logger.w('Google Sign-In cancelled by user');
        return null;
      }

      // Get authentication details
      final googleAuth = await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      _logger.i('Google Sign-In successful: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      _logger.e('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _logger.i('User signed out');
    } catch (e) {
      _logger.e('Error signing out: $e');
      rethrow;
    }
  }

  // ============================================================================
  // AUTHENTICATION STATE
  // ============================================================================

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Listen to authentication state changes
  void onAuthStateChanged(Function(User?) callback) {
    _auth.authStateChanges().listen(callback);
  }

  // ============================================================================
  // EMAIL/PASSWORD (Optional - for future use)
  // ============================================================================

  /// Create user with email and password
  Future<UserCredential> createUserWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _logger.e('Error creating user: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _logger.e('Error signing in: $e');
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _logger.i('Password reset email sent to: $email');
    } catch (e) {
      _logger.e('Error resetting password: $e');
      rethrow;
    }
  }
}
