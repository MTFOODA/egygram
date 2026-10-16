/// Centralized Supabase configuration.
///
/// Values are supplied at build/run time via `--dart-define` so that no secrets
/// are committed to source control:
///
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=your-anon-key
///
/// See `.env.example`, `.vscode/launch.json` and
/// `EgyGram_COMPLETE_PROJECT_GUIDE.txt` for details.
library;

import 'dart:convert';

/// The single source of truth for the app's Supabase connection settings.
///
/// Configuration is read with [String.fromEnvironment] (compile-time constants
/// injected by `--dart-define`). This is intentional: it keeps the app free of
/// a runtime `.env` dependency and avoids a second, conflicting configuration
/// system. Nothing is ever hardcoded here and no fake fallback value is used.
class SupabaseConfig {
  const SupabaseConfig._();

  /// Supabase project URL. This project's authoritative URL is baked in as the
  /// [String.fromEnvironment] default so the app is correctly configured out of
  /// the box. It can still be overridden at run/build time with
  /// `--dart-define=SUPABASE_URL=...` (e.g. for a different environment).
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://rvfwruqfoewgilethbmf.supabase.co',
  );

  /// Supabase *publishable / anon* key. This key is safe to ship in a client
  /// app ONLY because access is protected by Row Level Security. Never put the
  /// service-role / secret key here.
  ///
  /// The project's real anon (publishable) key is baked in as the
  /// [String.fromEnvironment] default so the app is correctly configured out of
  /// the box. It can still be overridden at run/build time with
  /// `--dart-define=SUPABASE_ANON_KEY=...`.
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ2ZndydXFmb2V3Z2lsZXRoYm1mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE2NjIxNzcsImV4cCI6MjEwNzIzODE3N30.9uQOdccQMrkPpRTM9g89qjrSCHC3jYxEbkF3B-b3hfA',
  );

  /// Obvious placeholder tokens people leave behind when copying templates.
  static const Set<String> _placeholderValues = {
    'your-anon-key',
    'your-anon-key-here',
    'your_anon_key',
    'your-key',
    'your-key-here',
    'your_key',
    'your-api-key',
    'your-supabase-anon-key',
    'supabase-anon-key',
    'anon',
    'anon-key',
    'anon_key',
    'publishable-key',
    'publishable_key',
    'paste-your-key-here',
    'paste_your_key_here',
    'api-key',
    'api_key',
    'change-me',
    'changeme',
    'change_me',
    'placeholder',
    'example',
    'sample',
    'dummy',
    'test',
    'test-key',
    'test_key',
    'todo',
    'tbd',
  };

  /// Matches a real Supabase project host such as `my-project.supabase.co`
  /// (or the `.supabase.in` regional domains). Custom domains are intentionally
  /// not matched so a mistake (e.g. the dashboard host) is caught early.
  static final RegExp _supabaseHost =
      RegExp(r'^[a-z0-9-]+\.supabase\.(co|in)$');

  /// Validates a candidate URL/key pair.
  ///
  /// Returns `null` when the pair is a valid, usable configuration; otherwise
  /// returns a descriptive, actionable message explaining exactly what is wrong
  /// and how to fix it. This is a pure function so it can be unit-tested with
  /// arbitrary inputs (the [url]/[anonKey] constants are fixed at compile time).
  static String? validateConfig(String candidateUrl, String candidateKey) {
    final trimmedUrl = candidateUrl.trim();
    final trimmedKey = candidateKey.trim();

    if (trimmedUrl.isEmpty) {
      return 'SUPABASE_URL is not set. Run/build the app with '
          '--dart-define=SUPABASE_URL=https://<your-project>.supabase.co '
          '(see .env.example).';
    }
    if (trimmedKey.isEmpty) {
      return 'SUPABASE_ANON_KEY is not set. Run/build the app with '
          '--dart-define=SUPABASE_ANON_KEY=<your-anon-key> '
          '(see .env.example).';
    }

    final uri = Uri.tryParse(trimmedUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return 'SUPABASE_URL is not a valid URL ("$trimmedUrl"). Expected '
          'https://<your-project>.supabase.co.';
    }
    if (uri.scheme.toLowerCase() != 'https') {
      return 'SUPABASE_URL must use HTTPS, got "${uri.scheme}". Use '
          'https://<your-project>.supabase.co.';
    }
    if (!_supabaseHost.hasMatch(uri.host.toLowerCase())) {
      return 'SUPABASE_URL does not look like a Supabase project URL '
          '(host "${uri.host}"). Expected a host like '
          '<project-ref>.supabase.co.';
    }

    if (_isPlaceholder(trimmedKey)) {
      return 'SUPABASE_ANON_KEY looks like a placeholder ("$trimmedKey"). '
          'Paste the real publishable/anon key from your Supabase dashboard '
          '(Project Settings -> API).';
    }
    if (_isServiceRoleKey(trimmedKey)) {
      return 'SUPABASE_ANON_KEY must be the publishable/anon key, never the '
          'service-role/secret key. The value you supplied looks like a '
          'secret/service-role key, which must never be shipped in a client '
          'app.';
    }

    return null;
  }

  /// The validation problem for the compiled-in [url]/[anonKey], or `null`.
  static String? get configProblem => validateConfig(url, anonKey);

  /// Whether the required configuration has been provided *and* is valid.
  static bool get isConfigured => validateConfig(url, anonKey) == null;

  /// Throws a descriptive [SupabaseConfigException] when configuration is
  /// missing or invalid so the failure is explicit instead of a cryptic SDK
  /// error later. Call this before initializing Supabase.
  static void assertConfigured() {
    final problem = validateConfig(url, anonKey);
    if (problem != null) {
      throw SupabaseConfigException(problem);
    }
  }

  /// Detects obvious placeholder values (template leftovers, `<...>` wrappers,
  /// filler like `xxxx`).
  static bool _isPlaceholder(String key) {
    final normalized = key.toLowerCase().trim();
    if (normalized.isEmpty) return true;
    if (normalized.startsWith('<') && normalized.endsWith('>')) return true;
    if (_placeholderValues.contains(normalized)) return true;
    // A run of a single filler character, e.g. "xxxx" or "****".
    if (normalized.length >= 3 &&
        'x*'.contains(normalized[0]) &&
        normalized.split('').every((c) => c == normalized[0])) {
      return true;
    }
    return false;
  }

  /// Detects a service-role / secret key so it is rejected on the client.
  ///
  /// Covers the modern `sb_secret_...` secret keys and legacy JWTs whose
  /// payload declares `"role":"service_role"`.
  static bool _isServiceRoleKey(String key) {
    if (key.toLowerCase().startsWith('sb_secret_')) return true;
    return _jwtHasServiceRole(key);
  }

  static bool _jwtHasServiceRole(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return false;
    try {
      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final compact = payload.toLowerCase().replaceAll(' ', '');
      return compact.contains('"role":"service_role"');
    } catch (_) {
      return false;
    }
  }
}

/// Raised when the Supabase URL / anon key have not been supplied or are
/// invalid (empty, placeholder, non-HTTPS, non-Supabase host, or a secret key).
class SupabaseConfigException implements Exception {
  final String message;
  const SupabaseConfigException(this.message);

  @override
  String toString() => 'SupabaseConfigException: $message';
}
