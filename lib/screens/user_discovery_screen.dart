import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/social_service.dart';
import 'user_profile_screen.dart';

class UserDiscoveryScreen extends StatefulWidget {
  const UserDiscoveryScreen({super.key});

  @override
  State<UserDiscoveryScreen> createState() => _UserDiscoveryScreenState();
}

class _UserDiscoveryScreenState extends State<UserDiscoveryScreen> with TickerProviderStateMixin {
  List<dynamic> _users = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedLevel;
  String? _selectedLanguage;
  int _currentPage = 1;
  bool _hasMoreData = true;
  Map<String, bool> _followStatus = {}; // Track follow status for each user
  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
    _scrollController.addListener(_onScroll);
  }


  Future<void> _loadFollowStatusForUsers(List<dynamic> users) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn || userProvider.currentUser == null) return;

    final currentUserId = userProvider.currentUser!.id;
    
    try {
      final following = await SocialService.getUserFollowing(currentUserId);
      final followingUsernames = following.map((user) => user['user_name'] as String).toSet();
      
      // Update follow status without triggering setState (will be done by caller)
      for (final user in users) {
        final userName = user['user_name'] as String;
        _followStatus[userName] = followingUsernames.contains(userName);
      }
    } catch (e) {
      print('Error loading follow status: $e');
    }
  }

  // Filter users based on follow status
  List<dynamic> get _notFollowingUsers {
    return _users.where((user) {
      final userName = user['user_name'] as String;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      // Don't show current user and users already following
      return userName != userProvider.currentUser?.userName && 
             (_followStatus[userName] ?? false) == false;
    }).toList();
  }

  List<dynamic> get _followingUsers {
    return _users.where((user) {
      final userName = user['user_name'] as String;
      // Show only users that are being followed
      return (_followStatus[userName] ?? false) == true;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMoreData) {
        _loadMoreUsers();
      }
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    try {
      final result = await SocialService.discoverUsers(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        level: _selectedLevel,
        language: _selectedLanguage,
        page: _currentPage,
      );

      final users = result['users'] ?? [];
      
      // Load follow status before updating UI to prevent flickering
      await _loadFollowStatusForUsers(users);
      
      setState(() {
        _users = users;
        _hasMoreData = result['has_next'] ?? false;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  Future<void> _loadMoreUsers() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final result = await SocialService.discoverUsers(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        level: _selectedLevel,
        language: _selectedLanguage,
        page: nextPage,
      );

      final newUsers = result['users'] ?? [];
      
      // Load follow status for new users before updating UI
      await _loadFollowStatusForUsers(newUsers);
      
      setState(() {
        _users.addAll(newUsers);
        _currentPage = nextPage;
        _hasMoreData = result['has_next'] ?? false;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading more users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _followUser(String targetUserName) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (!userProvider.isLoggedIn || userProvider.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to follow users'),
            backgroundColor: Color(0xFFE74C3C),
          ),
        );
        return;
      }

      final currentUserId = userProvider.currentUser!.id;
      final isCurrentlyFollowing = _followStatus[targetUserName] ?? false;
      
      // Show loading state
      setState(() {
        _followStatus[targetUserName] = !isCurrentlyFollowing; // Optimistically update UI
      });

      // Find the target user's ID from the users list
      final targetUser = _users.firstWhere(
        (user) => user['user_name'] == targetUserName,
        orElse: () => throw Exception('Target user not found'),
      );
      final targetUserId = targetUser['user_id'];

      final result = isCurrentlyFollowing 
          ? await SocialService.unfollowUser(targetUserId, currentUserId)
          : await SocialService.followUser(targetUserId, currentUserId);

      if (mounted) {
        // Update follow status based on actual response
        setState(() {
          _followStatus[targetUserName] = !isCurrentlyFollowing;
        });

        final action = !isCurrentlyFollowing ? 'followed' : 'unfollowed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully $action $targetUserName'),
            backgroundColor: const Color(0xFF27AE60),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error following user: $e');
      if (mounted) {
        // Revert optimistic update on error
        setState(() {
          _followStatus[targetUserName] = !_followStatus[targetUserName]!;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  void _navigateToUserProfile(String userName) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn || userProvider.currentUser == null) {
      return;
    }

    final isOwnProfile = userName == userProvider.currentUser!.userName;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          targetUserName: isOwnProfile ? null : userName,
          isViewingOtherProfile: !isOwnProfile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Discover Users',
          style: TextStyle(
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
              icon: const Icon(Icons.person_add, size: 20),
              text: 'Discover (${_notFollowingUsers.length})',
            ),
            Tab(
              icon: const Icon(Icons.people, size: 20),
              text: 'Following (${_followingUsers.length})',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF3498DB)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                              _loadUsers();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onSubmitted: (value) {
                    _loadUsers();
                  },
                ),
                const SizedBox(height: 12),
                // Filters Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedLevel,
                        decoration: InputDecoration(
                          labelText: 'Level',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Levels')),
                          ...['A1', 'A2', 'B1', 'B2', 'C1', 'C2'].map(
                            (level) => DropdownMenuItem(
                              value: level,
                              child: Text(level),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedLevel = value;
                          });
                          _loadUsers();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedLanguage,
                        decoration: InputDecoration(
                          labelText: 'Language',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Languages')),
                          ...['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese'].map(
                            (lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(lang),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedLanguage = value;
                          });
                          _loadUsers();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Discover Tab - Users not following yet
                _buildUserListTab(_notFollowingUsers),
                // Following Tab - Users already following
                _buildUserListTab(_followingUsers),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildUserListTab(List<dynamic> users) {
    return _isLoading && users.isEmpty
        ? const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF3498DB),
            ),
          )
        : users.isEmpty
            ? _buildEmptyStateForTab()
            : RefreshIndicator(
                onRefresh: _loadUsers,
                color: const Color(0xFF3498DB),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= users.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            color: Color(0xFF3498DB),
                          ),
                        ),
                      );
                    }

                    final user = users[index];
                    return _buildUserCard(user);
                  },
                ),
              );
  }

  Widget _buildEmptyStateForTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _tabController.index == 0 ? Icons.person_search : Icons.people_outline,
              size: 80,
              color: const Color(0xFFBDC3C7),
            ),
            const SizedBox(height: 16),
            Text(
              _tabController.index == 0 
                  ? 'No new users to discover'
                  : 'Not following anyone yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7F8C8D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _tabController.index == 0
                  ? 'Try adjusting your search filters or check back later'
                  : 'Start following users to see them here',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF95A5A6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final userName = user['user_name'] ?? 'Unknown';
    final userLevel = user['user_level'] ?? '';
    final targetLanguages = user['target_language'];
    final bio = user['bio'] ?? '';
    final avatarUrl = user['avatar_url'];

    // Format target languages
    String languagesText = '';
    if (targetLanguages is List && targetLanguages.isNotEmpty) {
      languagesText = targetLanguages.join(', ');
    } else if (targetLanguages is String) {
      languagesText = targetLanguages;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to user profile
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('View profile: $userName'),
              backgroundColor: const Color(0xFF3498DB),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF3498DB),
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _navigateToUserProfile(userName),
                      child: Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3498DB),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (userLevel.isNotEmpty || languagesText.isNotEmpty)
                      Text(
                        [
                          if (userLevel.isNotEmpty) userLevel,
                          if (languagesText.isNotEmpty) languagesText,
                        ].join(' • '),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    if (bio.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        bio,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFBDC3C7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Follow Button
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  if (!userProvider.isLoggedIn) {
                    return const SizedBox.shrink();
                  }
                  
                  // Don't show follow button for yourself
                  if (userProvider.currentUser?.userName == userName) {
                    return const SizedBox.shrink();
                  }

                  final isFollowing = _followStatus[userName] ?? false;
                  
                  return ElevatedButton.icon(
                    onPressed: () => _followUser(userName),
                    icon: Icon(
                      isFollowing ? Icons.person_remove : Icons.person_add,
                      size: 16,
                    ),
                    label: Text(isFollowing ? 'Unfollow' : 'Follow'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing 
                          ? const Color(0xFFE74C3C) 
                          : const Color(0xFF3498DB),
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
      ),
    );
  }

}
