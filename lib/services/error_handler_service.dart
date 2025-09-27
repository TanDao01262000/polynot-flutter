import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/user_provider.dart';

class ErrorHandlerService {
  // Global method to handle 401 errors and trigger logout
  static Future<void> handle401Error(BuildContext context, String errorMessage) async {
    print('🔐 ErrorHandlerService: Handling 401 error - $errorMessage');
    
    try {
      // Get UserProvider and trigger logout
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.handleTokenExpiration();
      
      // Show user-friendly message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Session expired. Please log in again.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      print('🔐 ErrorHandlerService: User logged out due to token expiration');
    } catch (e) {
      print('🔐 ErrorHandlerService: Error handling 401: $e');
    }
  }

  // Check if an error is a 401 authentication error
  static bool is401Error(dynamic error) {
    if (error == null) return false;
    
    final errorString = error.toString().toLowerCase();
    return errorString.contains('401') || 
           errorString.contains('unauthorized') ||
           errorString.contains('authentication required') ||
           errorString.contains('token is expired') ||
           errorString.contains('invalid jwt');
  }

  // Handle any error and check for 401
  static Future<void> handleError(BuildContext context, dynamic error) async {
    if (is401Error(error)) {
      await handle401Error(context, error.toString());
    }
  }
}
