import 'exceptions.dart';

/// Maps any thrown object into a concise, safe, user-facing message.
///
/// Business rules that decide *what* to show belong here so Cubits and widgets
/// stay free of backend-specific error parsing.
String friendlyError(Object error) {
  if (error is AppException) {
    return error.message;
  }
  if (error is AuthException) {
    return error.message;
  }
  final text = error.toString();
  // Guard against leaking very long / technical SDK dumps.
  if (text.length > 200) {
    return 'Something went wrong. Please try again.';
  }
  return text;
}

/// Maps common Supabase Auth error codes/messages to friendly copy.
String friendlyAuthError(Object error) {
  final raw = error.toString().toLowerCase();
  if (raw.contains('invalid login credentials')) {
    return 'Invalid email or password.';
  }
  if (raw.contains('user already registered') ||
      raw.contains('already been registered')) {
    return 'An account with this email already exists.';
  }
  if (raw.contains('email not confirmed')) {
    return 'Please confirm your email before signing in.';
  }
  if (raw.contains('password') && raw.contains('least')) {
    return 'Password is too weak. Use at least 6 characters.';
  }
  if (raw.contains('anonymous_provider_disabled')) {
    return 'This sign-in method is disabled.';
  }
  if (error is AppException) return error.message;
  return friendlyError(error);
}
