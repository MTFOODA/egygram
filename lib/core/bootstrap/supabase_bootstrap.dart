import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../di/service_locator.dart';

/// Brings the Supabase backend online at startup.
///
/// This is the single place that turns configuration into a live, wired
/// [SupabaseClient]. It runs the full, ordered sequence:
///
///   1. Read and validate the configuration (fails fast with a descriptive
///      [SupabaseConfigException] if URL/key are missing or invalid).
///   2. Initialize Supabase exactly once (the SDK itself skips re-initialization
///      if already initialized, so duplicate calls are safe).
///   3. Wire every repository through [sl] so no repository, provider, BLoC or
///      screen can touch the client before it exists.
///
/// It never initializes Supabase with empty/placeholder values, and it never
/// swallows an initialization error: callers receive a [SupabaseBootstrapResult]
/// describing the failure and surface it to the user.
class SupabaseBootstrap {
  const SupabaseBootstrap._();

  /// Initializes Supabase and the service locator.
  ///
  /// On success returns [SupabaseBootstrapResult.ok]. On failure returns a
  /// result carrying [SupabaseBootstrapResult.message] (never throws for the
  /// expected "not configured" case), so the UI can render an actionable
  /// diagnostic instead of crashing on a blank screen.
  static Future<SupabaseBootstrapResult> run() async {
    // 1. Validate configuration BEFORE touching the SDK.
    try {
      SupabaseConfig.assertConfigured();
    } on SupabaseConfigException catch (e) {
      return SupabaseBootstrapResult.failure(e.message);
    }

    // 2. Initialize Supabase with the real, validated values. The anon key is
    //    passed as `publishableKey` (the non-deprecated SDK parameter).
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.anonKey,
      );
    } catch (e, stack) {
      debugPrint('Supabase.initialize failed: $e\n$stack');
      return SupabaseBootstrapResult.failure(
        'Failed to connect to the Supabase backend.\n$e',
      );
    }

    // 3. Wire repositories to the now-live client.
    sl.init(Supabase.instance.client);
    return const SupabaseBootstrapResult.ok();
  }
}

/// Outcome of [SupabaseBootstrap.run].
class SupabaseBootstrapResult {
  /// Whether the backend is initialized and the service locator is wired.
  final bool ok;

  /// A user-facing diagnostic when [ok] is `false`; `null` otherwise.
  final String? message;

  const SupabaseBootstrapResult._({required this.ok, this.message});

  const SupabaseBootstrapResult.ok() : this._(ok: true);

  const SupabaseBootstrapResult.failure(String message)
      : this._(ok: false, message: message);
}
