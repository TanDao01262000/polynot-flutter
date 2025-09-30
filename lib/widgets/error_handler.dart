import 'dart:convert';
import 'package:flutter/material.dart';
import '../exceptions/api_exceptions.dart';

/// Centralized error handling system
class ErrorHandler {
  /// Show error message to user
  static void showError(BuildContext context, dynamic error) {
    String message = 'An unexpected error occurred';
    Color backgroundColor = Colors.red;
    IconData icon = Icons.error_outline;

    if (error is ApiException) {
      message = error.message;
      
      // Customize error display based on error type
      switch (error.runtimeType) {
        case NetworkException:
          backgroundColor = Colors.orange;
          icon = Icons.wifi_off;
          break;
        case AuthException:
          backgroundColor = Colors.red;
          icon = Icons.lock_outline;
          break;
        case ValidationException:
          backgroundColor = Colors.amber;
          icon = Icons.warning_outlined;
          break;
        case ServerException:
          backgroundColor = Colors.red;
          icon = Icons.dns;
          break;
        case TimeoutException:
          backgroundColor = Colors.orange;
          icon = Icons.timer_off;
          break;
        case RateLimitException:
          backgroundColor = Colors.purple;
          icon = Icons.speed;
          break;
        case NotFoundException:
          backgroundColor = Colors.grey;
          icon = Icons.search_off;
          break;
        case ForbiddenException:
          backgroundColor = Colors.red;
          icon = Icons.block;
          break;
        case ConflictException:
          backgroundColor = Colors.amber;
          icon = Icons.warning;
          break;
        case ServiceUnavailableException:
          backgroundColor = Colors.orange;
          icon = Icons.cloud_off;
          break;
      }
    } else if (error is String) {
      message = error;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Build error widget for display
  static Widget buildErrorWidget(
    String message,
    VoidCallback onRetry, {
    String? retryText,
    IconData? icon,
    Color? iconColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: iconColor ?? Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryText ?? 'Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading error widget
  static Widget buildLoadingErrorWidget(
    String message,
    VoidCallback onRetry,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.refresh,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Build network error widget
  static Widget buildNetworkErrorWidget(VoidCallback onRetry) {
    return buildErrorWidget(
      'No internet connection. Please check your network and try again.',
      onRetry,
      icon: Icons.wifi_off,
      iconColor: Colors.orange,
      retryText: 'Retry',
    );
  }

  /// Build server error widget
  static Widget buildServerErrorWidget(VoidCallback onRetry) {
    return buildErrorWidget(
      'Server is temporarily unavailable. Please try again later.',
      onRetry,
      icon: Icons.dns,
      iconColor: Colors.red,
      retryText: 'Retry',
    );
  }

  /// Build authentication error widget
  static Widget buildAuthErrorWidget(VoidCallback onRetry) {
    return buildErrorWidget(
      'Authentication failed. Please login again.',
      onRetry,
      icon: Icons.lock_outline,
      iconColor: Colors.red,
      retryText: 'Login',
    );
  }

  /// Build not found error widget
  static Widget buildNotFoundErrorWidget(VoidCallback onRetry) {
    return buildErrorWidget(
      'The requested content was not found.',
      onRetry,
      icon: Icons.search_off,
      iconColor: Colors.grey,
      retryText: 'Go Back',
    );
  }

  /// Handle API error and return appropriate exception
  static ApiException handleApiError(int statusCode, String responseBody) {
    String message = 'An error occurred';
    String? details;

    try {
      final data = jsonDecode(responseBody);
      message = data['detail'] ?? data['message'] ?? message;
      details = data['details']?.toString();
    } catch (e) {
      // If JSON parsing fails, use the raw response body
      message = responseBody.isNotEmpty ? responseBody : message;
    }

    switch (statusCode) {
      case 400:
        return ValidationException(message, statusCode: statusCode, details: details);
      case 401:
        return AuthException(message, statusCode: statusCode, details: details);
      case 403:
        return ForbiddenException(message, statusCode: statusCode, details: details);
      case 404:
        return NotFoundException(message, statusCode: statusCode, details: details);
      case 409:
        return ConflictException(message, statusCode: statusCode, details: details);
      case 429:
        return RateLimitException(message, statusCode: statusCode, details: details);
      case 500:
        return ServerException(message, statusCode: statusCode, details: details);
      case 502:
      case 503:
      case 504:
        return ServiceUnavailableException(message, statusCode: statusCode, details: details);
      default:
        return ApiException(message, statusCode: statusCode, details: details);
    }
  }

  /// Handle network error
  static NetworkException handleNetworkError(dynamic error) {
    String message = 'Network error occurred';
    
    if (error.toString().contains('timeout')) {
      message = 'Request timed out. Please try again.';
    } else if (error.toString().contains('connection')) {
      message = 'Connection failed. Please check your internet connection.';
    } else if (error.toString().contains('host')) {
      message = 'Unable to reach server. Please try again later.';
    }

    return NetworkException(message);
  }
}
