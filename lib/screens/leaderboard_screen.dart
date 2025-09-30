import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_provider.dart';
import '../providers/user_provider.dart';
import '../models/social_models.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeaderboard();
    });
  }

  Future<void> _loadLeaderboard() async {
    final socialProvider = Provider.of<SocialProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.isLoggedIn && userProvider.currentUser != null) {
      await socialProvider.loadLeaderboard(
        userName: userProvider.currentUser!.userName,
        limit: 50,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SocialProvider, UserProvider>(
      builder: (context, socialProvider, userProvider, child) {
        if (!userProvider.isLoggedIn) {
          return _buildLoginPrompt();
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: const Text(
              'Leaderboard',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: socialProvider.isLoadingLeaderboard
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF3498DB),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLeaderboard,
                  color: const Color(0xFF3498DB),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Leaderboard stats
                        _buildLeaderboardStats(socialProvider, userProvider),
                        
                        const SizedBox(height: 24),
                        
                        // Leaderboard list
                        _buildLeaderboardList(socialProvider),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildLoginPrompt() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
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
                  Icons.leaderboard_outlined,
                  size: 64,
                  color: Color(0xFF3498DB),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Join the Competition!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Login to see how you rank among other learners and compete for the top spot.',
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
      ),
    );
  }

  Widget _buildLeaderboardStats(SocialProvider socialProvider, UserProvider userProvider) {
    final leaderboard = socialProvider.leaderboard;
    final currentUserName = userProvider.currentUser?.userName ?? '';
    
    // Find user's rank in the leaderboard
    int userRank = 0;
    if (currentUserName.isNotEmpty && leaderboard.isNotEmpty) {
      print('🔐 Looking for user: $currentUserName');
      print('🔐 Available users: ${leaderboard.map((e) => e.userName).toList()}');
      final userIndex = leaderboard.indexWhere((entry) => entry.userName == currentUserName);
      print('🔐 User index found: $userIndex');
      userRank = userIndex >= 0 ? userIndex + 1 : 0;
      print('🔐 Calculated user rank: $userRank');
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF27AE60), Color(0xFF229954)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF27AE60).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.leaderboard,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            '${leaderboard.length}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'Active Learners',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Top Score', leaderboard.isNotEmpty ? '${leaderboard.first.totalPoints}' : '0', Icons.stars),
              _buildStatItem('Your Rank', userRank > 0 ? '#$userRank' : 'N/A', Icons.emoji_events),
              _buildStatItem('Competition', 'Active', Icons.trending_up),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
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

  Widget _buildLeaderboardList(SocialProvider socialProvider) {
    final leaderboard = socialProvider.leaderboard;
    
    if (leaderboard.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9ECEF)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 64,
              color: const Color(0xFFBDC3C7),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Rankings Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7F8C8D),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start learning to appear on the leaderboard!',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFBDC3C7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Learners',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        ...leaderboard.asMap().entries.map((entry) => 
          _buildLeaderboardEntry(entry.value, entry.key + 1)),
      ],
    );
  }

  Widget _buildLeaderboardEntry(LeaderboardEntry entry, int rank) {
    final isTopThree = rank <= 3;
    final rankColors = {
      1: const Color(0xFFFFD700), // Gold
      2: const Color(0xFFC0C0C0), // Silver
      3: const Color(0xFFCD7F32), // Bronze
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTopThree ? rankColors[rank]! : const Color(0xFFE9ECEF),
          width: isTopThree ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTopThree ? rankColors[rank] : const Color(0xFF3498DB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isTopThree ? Colors.white : Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      size: 14,
                      color: const Color(0xFFF39C12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.totalPoints} points',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F4FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Level ${entry.level}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF3498DB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Badges
          if (entry.badges.isNotEmpty)
            Row(
              children: entry.badges.take(3).map((badge) => 
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  child: Text(
                    badge,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ).toList(),
            ),
        ],
      ),
    );
  }
}