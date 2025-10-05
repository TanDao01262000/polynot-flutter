import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/social_service.dart';

class FollowersFollowingScreen extends StatefulWidget {
  final String targetUserName;
  final String initialTab; // 'followers' or 'following'

  const FollowersFollowingScreen({
    super.key,
    required this.targetUserName,
    this.initialTab = 'followers',
  });

  @override
  State<FollowersFollowingScreen> createState() => _FollowersFollowingScreenState();
}

class _FollowersFollowingScreenState extends State<FollowersFollowingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _followers = [];
  List<Map<String, dynamic>> _following = [];
  bool _isLoadingFollowers = false;
  bool _isLoadingFollowing = false;
  String? _followersError;
  String? _followingError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == 'following' ? 1 : 0,
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadFollowers(),
      _loadFollowing(),
    ]);
  }

  Future<void> _loadFollowers() async {
    setState(() {
      _isLoadingFollowers = true;
      _followersError = null;
    });

    try {
      final response = await SocialService.getFollowers(widget.targetUserName);
      setState(() {
        _followers = List<Map<String, dynamic>>.from(response['followers'] ?? []);
        _isLoadingFollowers = false;
      });
    } catch (e) {
      print('Error loading followers: $e');
      setState(() {
        _followersError = e.toString();
        _isLoadingFollowers = false;
      });
    }
  }

  Future<void> _loadFollowing() async {
    setState(() {
      _isLoadingFollowing = true;
      _followingError = null;
    });

    try {
      final response = await SocialService.getFollowing(widget.targetUserName);
      setState(() {
        _following = List<Map<String, dynamic>>.from(response['following'] ?? []);
        _isLoadingFollowing = false;
      });
    } catch (e) {
      print('Error loading following: $e');
      setState(() {
        _followingError = e.toString();
        _isLoadingFollowing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          widget.targetUserName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF3498DB),
          labelColor: const Color(0xFF3498DB),
          unselectedLabelColor: const Color(0xFF7F8C8D),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: [
            Tab(
              icon: const Icon(Icons.people, size: 20),
              text: 'Followers (${_followers.length})',
            ),
            Tab(
              icon: const Icon(Icons.person_add, size: 20),
              text: 'Following (${_following.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Followers Tab
          _buildFollowersTab(),
          // Following Tab
          _buildFollowingTab(),
        ],
      ),
    );
  }

  Widget _buildFollowersTab() {
    if (_isLoadingFollowers) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3498DB),
        ),
      );
    }

    if (_followersError != null) {
      return _buildErrorState(_followersError!, _loadFollowers);
    }

    if (_followers.isEmpty) {
      return _buildEmptyState(
        'No Followers Yet',
        'This user doesn\'t have any followers yet.',
        Icons.people_outline,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFollowers,
      color: const Color(0xFF3498DB),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _followers.length,
        itemBuilder: (context, index) {
          final follower = _followers[index];
          return _buildUserCard(follower, isFollowing: true);
        },
      ),
    );
  }

  Widget _buildFollowingTab() {
    if (_isLoadingFollowing) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3498DB),
        ),
      );
    }

    if (_followingError != null) {
      return _buildErrorState(_followingError!, _loadFollowing);
    }

    if (_following.isEmpty) {
      return _buildEmptyState(
        'Not Following Anyone',
        'This user is not following anyone yet.',
        Icons.person_add_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFollowing,
      color: const Color(0xFF3498DB),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _following.length,
        itemBuilder: (context, index) {
          final followingUser = _following[index];
          return _buildUserCard(followingUser, isFollowing: false);
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, {required bool isFollowing}) {
    final userName = user['user_name'] ?? 'Unknown';
    final userLevel = user['user_level'] ?? '';
    final avatarUrl = user['avatar_url'];
    final totalPoints = user['total_points'] ?? 0;
    final followersCount = user['followers_count'] ?? 0;
    final followingCount = user['following_count'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFBDC3C7),
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(width: 16),
            
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userLevel,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Stats
                  Row(
                    children: [
                      _buildStatChip('Points', totalPoints.toString(), Icons.stars),
                      const SizedBox(width: 8),
                      _buildStatChip('Followers', followersCount.toString(), Icons.people),
                      const SizedBox(width: 8),
                      _buildStatChip('Following', followingCount.toString(), Icons.person_add),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action button (if viewing own profile or if not following)
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                if (!userProvider.isLoggedIn || 
                    userProvider.currentUser?.userName == userName) {
                  return const SizedBox.shrink();
                }

                return ElevatedButton.icon(
                  onPressed: () => _handleFollowAction(userName, userProvider),
                  icon: const Icon(Icons.person_add, size: 16),
                  label: const Text('Follow'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: const Color(0xFF7F8C8D),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: const Color(0xFFBDC3C7),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7F8C8D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFBDC3C7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Color(0xFFE74C3C),
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7F8C8D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFollowAction(String targetUserName, UserProvider userProvider) async {
    try {
      final currentUser = userProvider.currentUser!.userName;
      
      final result = await SocialService.toggleFollow(
        targetUserName,
        currentUser,
      );

      if (mounted) {
        final action = result['following'] == true ? 'followed' : 'unfollowed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully $action $targetUserName'),
            backgroundColor: const Color(0xFF27AE60),
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Refresh the data to update counts
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }
}
