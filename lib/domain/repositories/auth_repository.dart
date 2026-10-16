/// Authentication contract. Implemented in the data layer with Supabase Auth.
abstract class AuthRepository {
  /// The currently authenticated user's UUID, or null when signed out.
  String? get currentUserId;

  /// Whether a session is currently active.
  bool get isAuthenticated;

  /// Emits on auth state changes (sign-in / sign-out / token refresh).
  Stream<bool> get authStateChanges;

  /// Signs in with email + password. Throws [AuthException] on failure.
  Future<void> signIn({required String email, required String password});

  /// Registers a new account and creates its profile row.
  /// Throws [AuthException] on failure.
  Future<void> signUp({
    required String email,
    required String password,
    required String userName,
  });

  /// Signs the current user out.
  Future<void> signOut();

  /// Sends a password-reset email.
  Future<void> sendPasswordResetEmail(String email);
}
