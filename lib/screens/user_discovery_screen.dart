import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/social_service.dart';

class UserDiscoveryScreen extends StatefulWidget {
  const UserDiscoveryScreen({super.key});

  @override
  State<UserDiscoveryScreen> createState() => _UserDiscoveryScreenState();
}

class _UserDiscoveryScreenState extends State<UserDiscoveryScreen> {
  List<dynamic> _users = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedLevel;
  String? _selectedLanguage;
  int _currentPage = 1;
  bool _hasMoreData = true;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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

      setState(() {
        _users = result['users'] ?? [];
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

      setState(() {
        _users.addAll(result['users'] ?? []);
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

      final result = await SocialService.toggleFollow(
        targetUserName,
        userProvider.currentUser!.userName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Follow toggled'),
            backgroundColor: const Color(0xFF27AE60),
          ),
        );
      }
    } catch (e) {
      print('Error following user: $e');
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
          // User List
          Expanded(
            child: _isLoading && _users.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3498DB),
                    ),
                  )
                : _users.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        color: const Color(0xFF3498DB),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _users.length + (_isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _users.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF3498DB),
                                  ),
                                ),
                              );
                            }

                            final user = _users[index];
                            return _buildUserCard(user);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: const Color(0xFFBDC3C7),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Users Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7F8C8D),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search filters',
              style: TextStyle(
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
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
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

                  return ElevatedButton.icon(
                    onPressed: () => _followUser(userName),
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
      ),
    );
  }
}
