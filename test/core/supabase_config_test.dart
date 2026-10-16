import 'dart:convert';

import 'package:flutter_application_3/core/config/supabase_config.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the centralized Supabase configuration.
///
/// `SupabaseConfig.url` / `anonKey` are compile-time `String.fromEnvironment`
/// constants. They default to the project's authoritative URL and anon key
/// (baked into the source) but can be overridden with `--dart-define`, so their
/// *values* depend on the flags used to launch `flutter test`. The validation
/// *logic* is therefore exercised through the pure [SupabaseConfig.validateConfig]
/// helper, which accepts arbitrary inputs. The compiled-in *defaults* are
/// asserted separately at the bottom: a plain `flutter test` (no `--dart-define`)
/// must already be a valid, correctly-configured setup.

/// A syntactically valid, non-placeholder anon key (a real anon JWT whose
/// payload has role "anon").
const _validAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
    'eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIn0.'
    'c2lnbmF0dXJlLWZvci10ZXN0LW9ubHk';

/// Builds a JWT-shaped token with the given payload role.
String _jwt(String role) {
  String b64(String s) => base64Url.encode(utf8.encode(s)).replaceAll('=', '');
  return '${b64('{"alg":"HS256","typ":"JWT"}')}'
      '.${b64('{"role":"$role","iss":"supabase"}')}'
      '.c2ln';
}

void main() {
  const validUrl = 'https://rvfwruqfoewgilethbmf.supabase.co';

  group('validateConfig - correctly supplied configuration', () {
    test('accepts a valid HTTPS Supabase URL and a real anon key', () {
      expect(SupabaseConfig.validateConfig(validUrl, _validAnonKey), isNull);
    });

    test('accepts the .supabase.in regional host form', () {
      expect(
        SupabaseConfig.validateConfig(
          'https://my-project.supabase.in',
          _validAnonKey,
        ),
        isNull,
      );
    });

    test('tolerates surrounding whitespace', () {
      expect(
        SupabaseConfig.validateConfig('  $validUrl \n', '  $_validAnonKey '),
        isNull,
      );
    });
  });

  group('validateConfig - missing values', () {
    test('reports a missing URL', () {
      final problem = SupabaseConfig.validateConfig('', _validAnonKey);
      expect(problem, isNotNull);
      expect(problem, contains('SUPABASE_URL'));
      expect(problem, contains('--dart-define'));
    });

    test('reports a missing client key', () {
      final problem = SupabaseConfig.validateConfig(validUrl, '');
      expect(problem, isNotNull);
      expect(problem, contains('SUPABASE_ANON_KEY'));
    });

    test('missing URL is reported before missing key', () {
      final problem = SupabaseConfig.validateConfig('', '');
      expect(problem, contains('SUPABASE_URL'));
    });
  });

  group('validateConfig - invalid URL', () {
    test('rejects a non-URL string', () {
      final problem = SupabaseConfig.validateConfig('not a url', _validAnonKey);
      expect(problem, isNotNull);
      expect(problem, contains('not a valid URL'));
    });

    test('rejects a non-HTTPS (http) URL', () {
      final problem = SupabaseConfig.validateConfig(
        'http://rvfwruqfoewgilethbmf.supabase.co',
        _validAnonKey,
      );
      expect(problem, isNotNull);
      expect(problem, contains('HTTPS'));
    });

    test('rejects a URL whose host is not a Supabase project host', () {
      final problem =
          SupabaseConfig.validateConfig('https://example.com', _validAnonKey);
      expect(problem, isNotNull);
      expect(problem, contains('does not look like a Supabase project URL'));
    });

    test('rejects the dashboard host (not the project API host)', () {
      final problem = SupabaseConfig.validateConfig(
        'https://supabase.com/dashboard',
        _validAnonKey,
      );
      expect(problem, isNotNull);
    });
  });

  group('validateConfig - placeholder configuration values', () {
    test('rejects the .env.example placeholder key', () {
      final problem = SupabaseConfig.validateConfig(validUrl, 'YOUR-ANON-KEY');
      expect(problem, isNotNull);
      expect(problem, contains('placeholder'));
    });

    test('rejects an angle-bracket template value', () {
      final problem = SupabaseConfig.validateConfig(
        validUrl,
        '<PASTE_YOUR_KEY_HERE>',
      );
      expect(problem, isNotNull);
      expect(problem, contains('placeholder'));
    });

    test('rejects filler values like xxxx', () {
      expect(SupabaseConfig.validateConfig(validUrl, 'xxxx'), isNotNull);
      expect(SupabaseConfig.validateConfig(validUrl, '****'), isNotNull);
    });
  });

  group('validateConfig - secret/service-role key is rejected on the client', () {
    test('rejects a modern sb_secret_ key', () {
      final problem = SupabaseConfig.validateConfig(
        validUrl,
        'sb_secret_1234567890abcdef',
      );
      expect(problem, isNotNull);
      expect(problem!.toLowerCase(), contains('service-role'));
    });

    test('rejects a legacy service_role JWT', () {
      final problem = SupabaseConfig.validateConfig(validUrl, _jwt('service_role'));
      expect(problem, isNotNull);
      expect(problem!.toLowerCase(), contains('service-role'));
    });

    test('still accepts an anon-role JWT', () {
      expect(SupabaseConfig.validateConfig(validUrl, _jwt('anon')), isNull);
    });
  });

  group('compiled-in defaults (no --dart-define needed)', () {
    // `SupabaseConfig` bakes the project's authoritative URL and anon key in as
    // `String.fromEnvironment` defaults, so a plain `flutter test` / `flutter
    // run` (with no --dart-define) is already correctly configured. These tests
    // document that shipped default and that it is a *valid* configuration.
    test('the default URL is the authoritative project URL', () {
      expect(SupabaseConfig.url, 'https://rvfwruqfoewgilethbmf.supabase.co');
    });

    test('the default anon key is present and is not a service-role key', () {
      expect(SupabaseConfig.anonKey, isNotEmpty);
      // A shipped client key must never be a service_role/secret key.
      expect(SupabaseConfig.anonKey.toLowerCase(), isNot(contains('service_role')));
      expect(SupabaseConfig.anonKey.toLowerCase(), isNot(startsWith('sb_secret_')));
    });

    test('the shipped defaults are a valid configuration', () {
      expect(SupabaseConfig.isConfigured, isTrue);
      expect(SupabaseConfig.configProblem, isNull);
      expect(
        SupabaseConfig.validateConfig(SupabaseConfig.url, SupabaseConfig.anonKey),
        isNull,
      );
    });

    test('assertConfigured does not throw with the shipped defaults', () {
      expect(SupabaseConfig.assertConfigured, returnsNormally);
    });
  });
}
