/// Custom exception classes for API error handling
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;
  final String? errorCode;

  ApiException(
    this.message, {
    this.statusCode,
    this.details,
    this.errorCode,
  });

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (${statusCode})' : ''}';
}

/// Network-related exceptions
class NetworkException extends ApiException {
  NetworkException(String message, {int? statusCode, String? details})
      : super(message, statusCode: statusCode, details: details, errorCode: 'NETWORK_ERROR');
}

/// Authentication-related exceptions
class AuthException extends ApiException {
  AuthException(String message, {int? statusCode, String? details})
      : super(message, statusCode: statusCode, details: details, errorCode: 'AUTH_ERROR');
}

/// Validation-related exceptions
class ValidationException extends ApiException {
  ValidationException(String message, {int? statusCode, String? details})
      : super(message, statusCode: statusCode, details: details, errorCode: 'VALIDATION_ERROR');
}

/// Server-related exceptions
class ServerException extends ApiException {
  ServerException(String message, {int? statusCode, String? details})
      : super(message, statusCode: statusCode, details: details, errorCode: 'SERVER_ERROR');
}

/// Timeout exceptions
class TimeoutException extends ApiException {
  TimeoutException(String message, {int? statusCode, String? details})
      : super(message, statusCode: statusCode, details: details, errorCode: 'TIMEOUT_ERROR');
}

/// Rate limiting exceptions
class RateLimitException extends ApiException {
  RateLimitException(String message, {int? statusCode, String? details})
      : super(message, statusCode: statusCode, details: details, errorCode: 'RATE_LIMIT_ERROR');
}

/// Not found exceptions
class NotFoundException extends ApiException {
  NotFoundException(String message, {int? statusCode, String? details})
      : super(message, statusCode: statusCode, details: details, errorCode: 'NOT_FOUND_ERROR');
}

/// Forbidden exceptions
class ForbiddenException extends ApiException {
  ForbiddenException(String message, {int? statusCode, String? details})
      : super(message, statusCode: statusCode, details: details, errorCode: 'FORBIDDEN_ERROR');
}

/// Conflict exceptions
class ConflictException extends ApiException {
  ConflictException(String message, {int? statusCode, String? details})
      : super(message, statusCode: statusCode, details: details, errorCode: 'CONFLICT_ERROR');
}

/// Service unavailable exceptions
class ServiceUnavailableException extends ApiException {
  ServiceUnavailableException(String message, {int? statusCode, String? details})
      : super(message, statusCode: statusCode, details: details, errorCode: 'SERVICE_UNAVAILABLE_ERROR');
}
