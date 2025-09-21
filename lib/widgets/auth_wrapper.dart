import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/home_screen.dart';
import '../screens/user_login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      print('🔐 AuthWrapper: Initializing authentication...');
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Use post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await userProvider.initializeAuth();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
        print('🔐 AuthWrapper: Authentication initialization complete');
      });
    } catch (e) {
      print('🔐 AuthWrapper: Authentication initialization failed: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing app...'),
            ],
          ),
        ),
      );
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Show loading screen while checking authentication
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Checking authentication...'),
                ],
              ),
            ),
          );
        }

        // Navigate based on authentication status
        if (userProvider.isLoggedIn) {
          print('🔐 AuthWrapper: User is logged in, showing home screen');
          return const HomeScreen();
        } else {
          print('🔐 AuthWrapper: User is not logged in, showing login screen');
          return const UserLoginScreen();
        }
      },
    );
  }
}

