import 'package:flutter_application_3/core/errors/error_mapper.dart';
import 'package:flutter_application_3/core/errors/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('friendlyError', () {
    test('returns the message of an AppException verbatim', () {
      expect(
        friendlyError(const ServerException('db unavailable')),
        'db unavailable',
      );
    });

    test('returns the message of an AuthException verbatim', () {
      expect(friendlyError(const AuthException('session expired')),
          'session expired');
    });

    test('truncates very long SDK dumps into safe copy', () {
      final long = Exception('x' * 300).toString();
      expect(friendlyError(Exception(long)),
          'Something went wrong. Please try again.');
    });

    test('passes through short non-exception text', () {
      expect(friendlyError('boom'), 'boom');
    });
  });

  group('friendlyAuthError', () {
    test('maps invalid login credentials', () {
      expect(
        friendlyAuthError(Exception('Invalid login credentials')),
        'Invalid email or password.',
      );
    });

    test('maps already registered', () {
      expect(
        friendlyAuthError(Exception('User already registered')),
        'An account with this email already exists.',
      );
    });

    test('maps unconfirmed email', () {
      expect(
        friendlyAuthError(Exception('Email not confirmed')),
        'Please confirm your email before signing in.',
      );
    });

    test('maps weak password', () {
      expect(
        friendlyAuthError(
            Exception('Password should be at least 6 characters')),
        'Password is too weak. Use at least 6 characters.',
      );
    });

    test('falls back to AppException message', () {
      expect(
        friendlyAuthError(const AuthException('Sign-up disabled')),
        'Sign-up disabled',
      );
    });
  });
}
