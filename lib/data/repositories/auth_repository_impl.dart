import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../core/constants/app_constants.dart';
import '../../core/errors/error_mapper.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../utilities/sp.dart';

/// Supabase Auth implementation.
///
/// Sign-up creates the auth user and then inserts a matching `profiles` row
/// keyed by the new auth UUID, preserving the app's `user_name` identity.
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  SupabaseQueryBuilder get _profiles => _client.from(DbTables.profiles);

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  bool get isAuthenticated => _client.auth.currentSession != null;

  @override
  Stream<bool> get authStateChanges =>
      _client.auth.onAuthStateChange.map((event) => event.session != null);

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      // When email confirmation is enabled, signUp could not create the
      // profile row because there was no session yet. Complete it now, on
      // first successful sign-in.
      await _bootstrapProfileIfNeeded(email: email);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(friendlyAuthError(e), code: 'sign_in_failed');
    }
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String userName,
  }) async {
    try {
      final response =
          await _client.auth.signUp(email: email, password: password);

      final user = response.user;
      if (user != null) {
        // Create the profile row. If email confirmation is required there is
        // no session yet, so the insert is deferred to first sign-in via the
        // sign-in hook in [signIn]; otherwise create it now.
        if (response.session != null) {
          await _ensureProfile(
              userId: user.id, email: email, userName: userName);
        }
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(friendlyAuthError(e), code: 'sign_up_failed');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AuthException(friendlyError(e), code: 'sign_out_failed');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthException(friendlyError(e), code: 'reset_failed');
    }
  }

  /// Ensures a profile row exists for the signed-in user. Idempotent: an
  /// existing `user_name` is preserved, only missing fields are filled.
  Future<void> ensureProfile(
      {required String email, required String userName}) async {
    final userId = currentUserId;
    if (userId == null) {
      throw const AuthException('No authenticated user.', code: 'no_user');
    }
    await _ensureProfile(userId: userId, email: email, userName: userName);
  }

  Future<void> _ensureProfile({
    required String userId,
    required String email,
    required String userName,
  }) async {
    final existing = await _profiles.select().eq('id', userId).maybeSingle();

    if (existing != null) return;

    await _profiles.insert({
      'id': userId,
      'user_name': userName,
      'email': email,
      'number_of_posts': 0,
      'number_of_followers': 0,
      'number_of_following': 0,
    });
  }

  /// Creates the missing profile row after a deferred sign-up (email
  /// confirmation flow). Never throws: a conflicting name falls back to a
  /// uuid-derived one so sign-in itself cannot fail on profile bookkeeping.
  Future<void> _bootstrapProfileIfNeeded({required String email}) async {
    final userId = currentUserId;
    if (userId == null) return;

    final existing =
        await _profiles.select('id').eq('id', userId).maybeSingle();
    if (existing != null) return;

    // The sign-up screen caches the chosen user name before navigating.
    var userName = (CacheHelper.getData('user') as String?)?.trim() ?? '';
    if (userName.isEmpty) {
      userName = email.split('@').first;
    }

    try {
      await _ensureProfile(userId: userId, email: email, userName: userName);
    } catch (_) {
      // user_name collision: retry with a unique uuid-derived name.
      try {
        await _ensureProfile(
          userId: userId,
          email: email,
          userName: '${userName}_${userId.substring(0, 8)}',
        );
      } catch (_) {
        // Ignore: the profile can be completed on a later sign-in.
      }
    }
  }
}
