import 'package:supabase_flutter/supabase_flutter.dart';

// ════════════════════════════════════════════════════════════════
// NEXIIA — Auth Service
// ════════════════════════════════════════════════════════════════
//
// Clean wrapper around Supabase Auth.
// All auth logic lives here — screens never call Supabase directly.
//
// Usage:
//   final authService = AuthService();
//   await authService.signIn(email: '...', password: '...');
// ════════════════════════════════════════════════════════════════

class AuthService {
  final GoTrueClient _auth = Supabase.instance.client.auth;

  // ── Current State ──────────────────────────

  /// Currently signed-in user, or null.
  User? get currentUser => _auth.currentUser;

  /// Whether a user is currently signed in.
  bool get isSignedIn => _auth.currentUser != null;

  /// Current session, or null.
  Session? get currentSession => _auth.currentSession;

  /// Stream of auth state changes (sign in, sign out, token refresh).
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  // ── Sign In ────────────────────────────────

  /// Sign in with email and password.
  /// Throws [AuthException] on failure.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    return response;
  }

  // ── Sign Up ────────────────────────────────

  /// Create a new account with email and password.
  /// Throws [AuthException] on failure.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _auth.signUp(
      email: email.trim(),
      password: password,
    );
    return response;
  }

  // ── Sign Out ───────────────────────────────

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Password Reset ─────────────────────────

  /// Send a password reset email.
  /// Throws [AuthException] on failure.
  Future<void> resetPassword({required String email}) async {
    await _auth.resetPasswordForEmail(email.trim());
  }

  // ── Session Check ──────────────────────────

  /// Check if there is a valid existing session.
  /// Used on app start to decide: show auth or go to home.
  Future<bool> hasValidSession() async {
    try {
      final session = _auth.currentSession;
      if (session == null) return false;
      if (session.isExpired) return false;
      return true;
    } catch (_) {
      return false;
    }
  }
}