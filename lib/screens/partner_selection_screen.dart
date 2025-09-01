import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/partner.dart';
import '../widgets/partner_card.dart';
import '../services/partner_service.dart';
import '../providers/user_provider.dart';
import 'user_login_screen.dart';

class PartnerSelectScreen extends StatefulWidget {
  const PartnerSelectScreen({super.key});

  @override
  State<PartnerSelectScreen> createState() => _PartnerSelectScreenState();
}

class _PartnerSelectScreenState extends State<PartnerSelectScreen> {
  List<Partner> partnerList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get current user's username before any async operations
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      final userName = currentUser?.userName;

      // Check if user is logged in
      if (userName == null) {
        setState(() {
          _isLoading = false;
          _error = 'login_required';
        });
        return;
      }

      // Check API health first
      await PartnerService.checkHealth();
      print('API health check passed');

      // Fetch partners for the current user
      final partners = await PartnerService.fetchAllPartners(userName);
      
      // Check if widget is still mounted before updating state
      if (mounted) {
        setState(() {
          partnerList = partners;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to connect to server: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadPartners() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get current user's username before any async operations
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      final userName = currentUser?.userName;

      // Check if user is logged in
      if (userName == null) {
        setState(() {
          _isLoading = false;
          _error = 'login_required';
        });
        return;
      }

      // Fetch partners for the current user
      final partners = await PartnerService.fetchAllPartners(userName);
      
      // Check if widget is still mounted before updating state
      if (mounted) {
        setState(() {
          partnerList = partners;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load partners: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserLoginScreen()),
    ).then((_) {
      // Reload partners after login
      _loadPartners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a partner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPartners,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error == 'login_required') {
      return _buildLoginPrompt();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPartners,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (partnerList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No partners available',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Check back later for new conversation partners!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPartners,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: partnerList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PartnerCard(partner: partnerList[index]),
          );
        },
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Start Chatting with AI Partners',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Login to access our AI conversation partners and start meaningful conversations. Your chat history will be saved and personalized just for you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _navigateToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Login to Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Navigate to registration screen
                Navigator.pushNamed(context, '/register');
              },
              child: const Text(
                'Don\'t have an account? Sign up',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}