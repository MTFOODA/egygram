/// Typed exceptions thrown by the data layer.
///
/// Repositories throw these; Cubits convert them into user-friendly messages
/// via [friendlyError] so raw SDK errors never leak to the UI.
library;

/// Base class for all data-layer exceptions.
class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException($code): $message';
}

/// Authentication / authorization failure (login, signup, session).
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// Database read/write failure (PostgREST).
class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

/// Storage upload/download failure.
class StorageException extends AppException {
  const StorageException(super.message, {super.code});
}

/// A requested record was not found.
class NotFoundException extends AppException {
  const NotFoundException(super.message) : super(code: 'not_found');
}
