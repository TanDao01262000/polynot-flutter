import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/partner.dart';
import '../widgets/partner_card.dart';
import '../services/partner_service.dart';
import '../providers/user_provider.dart';

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeApp,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView.builder(
                          itemCount: partnerList.length,
                          itemBuilder: (context, index) {
                            return PartnerCard(partner: partnerList[index]);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
    );
  }
}