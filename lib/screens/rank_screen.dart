import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_provider.dart';
import '../providers/user_provider.dart';
import '../models/social_models.dart';
import 'achievements_screen.dart';
import 'leaderboard_screen.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final socialProvider = Provider.of<SocialProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.isLoggedIn && userProvider.currentUser != null) {
      await Future.wait([
        socialProvider.loadUserPoints(userProvider.currentUser!.id),
        socialProvider.loadAchievements(userProvider.currentUser!.id),
        socialProvider.loadLeaderboard(userId: userProvider.currentUser!.id, limit: 20),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Gamification',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3498DB),
          unselectedLabelColor: const Color(0xFF7F8C8D),
          indicatorColor: const Color(0xFF3498DB),
          tabs: const [
            Tab(text: 'Points'),
            Tab(text: 'Achievements'),
            Tab(text: 'Leaderboard'),
          ],
        ),
      ),
      body: Consumer2<SocialProvider, UserProvider>(
        builder: (context, socialProvider, userProvider, child) {
          if (!userProvider.isLoggedIn) {
            return _buildLoginPrompt();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPointsTab(socialProvider, userProvider),
              const AchievementsScreen(),
              const LeaderboardScreen(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4FD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: Color(0xFF3498DB),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Track Your Progress!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Login to earn points, unlock achievements, and compete on the leaderboard.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7F8C8D),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Login to Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsTab(SocialProvider socialProvider, UserProvider userProvider) {
    if (socialProvider.isLoadingPoints) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3498DB),
        ),
      );
    }

    final userPoints = socialProvider.userPoints;
    if (userPoints == null) {
      return const Center(
        child: Text(
          'Failed to load points data',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF7F8C8D),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (userProvider.currentUser != null) {
          await socialProvider.loadUserPoints(userProvider.currentUser!.id);
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Points summary card
            _buildPointsSummaryCard(userPoints, socialProvider),
            
            const SizedBox(height: 24),
            
            // Level progress card
            _buildLevelProgressCard(userPoints, socialProvider),
            
            const SizedBox(height: 24),
            
            // Points breakdown card
            _buildPointsBreakdownCard(userPoints),
            
            const SizedBox(height: 24),
            
            // Recent activity card
            _buildRecentActivityCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsSummaryCard(UserPoints userPoints, SocialProvider socialProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3498DB).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.stars,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            '${userPoints.totalPoints}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'Total Points',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPointsStat('Available', '${userPoints.availablePoints}', Icons.account_balance_wallet),
              _buildPointsStat('Redeemed', '${userPoints.redeemedPoints}', Icons.redeem),
              _buildPointsStat('Level', '${userPoints.level}', Icons.trending_up),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelProgressCard(UserPoints userPoints, SocialProvider socialProvider) {
    final progressPercentage = socialProvider.getLevelProgressPercentage();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: Color(0xFF3498DB),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Level ${userPoints.level}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  socialProvider.getLevelDisplayName(userPoints.level),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF27AE60),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${userPoints.totalPoints} / ${userPoints.nextLevelPoints} points',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressPercentage / 100,
            backgroundColor: const Color(0xFFE9ECEF),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '${(progressPercentage).toInt()}% to next level',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsBreakdownCard(UserPoints userPoints) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: Color(0xFF3498DB),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Points Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBreakdownItem(
            'Available Points',
            userPoints.availablePoints,
            const Color(0xFF27AE60),
            Icons.account_balance_wallet,
          ),
          _buildBreakdownItem(
            'Redeemed Points',
            userPoints.redeemedPoints,
            const Color(0xFFE74C3C),
            Icons.redeem,
          ),
          _buildBreakdownItem(
            'Total Points',
            userPoints.totalPoints,
            const Color(0xFF3498DB),
            Icons.stars,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String label, int value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5D6D7E),
              ),
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.history,
                color: Color(0xFF3498DB),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'No recent activity',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start learning to earn points and unlock achievements!',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFBDC3C7),
            ),
          ),
        ],
      ),
    );
  }
}


