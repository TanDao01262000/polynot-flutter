import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordService {
  static const String _passwordPrefix = 'user_password_';
  
  // Store user password (hashed) during registration
  static Future<void> storePassword(String userName, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final hashedPassword = _hashPassword(password);
    await prefs.setString('$_passwordPrefix$userName', hashedPassword);
  }
  
  // Verify password during login
  static Future<bool> verifyPassword(String userName, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHashedPassword = prefs.getString('$_passwordPrefix$userName');
    
    if (storedHashedPassword == null) {
      return false; // No password stored for this user
    }
    
    final inputHashedPassword = _hashPassword(password);
    return storedHashedPassword == inputHashedPassword;
  }
  
  // Hash password using SHA-256 (in production, use bcrypt or similar)
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Remove stored password (for testing or user deletion)
  static Future<void> removePassword(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_passwordPrefix$userName');
  }
  
  // Check if user has a stored password
  static Future<bool> hasStoredPassword(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_passwordPrefix$userName');
  }
}
