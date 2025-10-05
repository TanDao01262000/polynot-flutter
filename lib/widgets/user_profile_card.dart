import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/social_service.dart';
import '../screens/followers_following_screen.dart';

class UserProfileCard extends StatefulWidget {
  final String userName;
  final String? userLevel;
  final String? avatarUrl;
  final String? bio;
  final List<String>? targetLanguages;
  final int? totalPoints;
  final int? followersCount;
  final int? followingCount;
  final bool showFollowButton;
  final VoidCallback? onFollowChanged;

  const UserProfileCard({
    super.key,
    required this.userName,
    this.userLevel,
    this.avatarUrl,
    this.bio,
    this.targetLanguages,
    this.totalPoints,
    this.followersCount,
    this.followingCount,
    this.showFollowButton = true,
    this.onFollowChanged,
  });

  @override
  State<UserProfileCard> createState() => _UserProfileCardState();
}

class _UserProfileCardState extends State<UserProfileCard> {
  bool _isFollowing = false;
  bool _isLoadingFollow = false;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn || 
        userProvider.currentUser?.userName == widget.userName) {
      return;
    }

    try {
      final isFollowing = await SocialService.isFollowing(
        userProvider.currentUser!.userName,
        widget.userName,
      );
      
      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
        });
      }
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  Future<void> _handleFollowAction() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn || 
        userProvider.currentUser?.userName == widget.userName) {
      return;
    }

    setState(() {
      _isLoadingFollow = true;
    });

    try {
      final currentUser = userProvider.currentUser!.userName;
      
      final result = await SocialService.toggleFollow(
        widget.userName,
        currentUser,
      );

      if (mounted) {
        setState(() {
          _isFollowing = result['following'] ?? false;
          _isLoadingFollow = false;
        });

        final action = _isFollowing ? 'followed' : 'unfollowed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully $action ${widget.userName}'),
            backgroundColor: const Color(0xFF27AE60),
            duration: const Duration(seconds: 2),
          ),
        );
        
        widget.onFollowChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFollow = false;
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile header
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFBDC3C7),
                  backgroundImage: widget.avatarUrl != null 
                      ? NetworkImage(widget.avatarUrl!) 
                      : null,
                  child: widget.avatarUrl == null
                      ? Text(
                          widget.userName.isNotEmpty 
                              ? widget.userName[0].toUpperCase() 
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        )
                      : null,
                ),
                
                const SizedBox(width: 20),
                
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      if (widget.userLevel != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.userLevel!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                      ],
                      if (widget.targetLanguages != null && widget.targetLanguages!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: widget.targetLanguages!.map((lang) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3498DB).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                lang,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3498DB),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Follow button
                if (widget.showFollowButton)
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      if (!userProvider.isLoggedIn || 
                          userProvider.currentUser?.userName == widget.userName) {
                        return const SizedBox.shrink();
                      }

                      return ElevatedButton.icon(
                        onPressed: _isLoadingFollow ? null : _handleFollowAction,
                        icon: _isLoadingFollow
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(
                                _isFollowing ? Icons.person_remove : Icons.person_add,
                                size: 16,
                              ),
                        label: Text(_isFollowing ? 'Unfollow' : 'Follow'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFollowing 
                              ? const Color(0xFFE74C3C) 
                              : const Color(0xFF3498DB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                
              ],
            ),
            
            // Bio
            if (widget.bio != null && widget.bio!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.bio!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5D6D7E),
                    height: 1.5,
                  ),
                ),
              ),
            ],
            
            // Stats
            const SizedBox(height: 20),
            Row(
              children: [
                _buildStatItem(
                  'Points',
                  widget.totalPoints?.toString() ?? '0',
                  Icons.stars,
                  const Color(0xFFF39C12),
                ),
                _buildStatItem(
                  'Followers',
                  widget.followersCount?.toString() ?? '0',
                  Icons.people,
                  const Color(0xFF3498DB),
                ),
                _buildStatItem(
                  'Following',
                  widget.followingCount?.toString() ?? '0',
                  Icons.person_add,
                  const Color(0xFF27AE60),
                ),
              ],
            ),
            
            // Action buttons
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FollowersFollowingScreen(
                            targetUserName: widget.userName,
                            initialTab: 'followers',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.people, size: 16),
                    label: const Text('Followers'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3498DB),
                      side: const BorderSide(color: Color(0xFF3498DB)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FollowersFollowingScreen(
                            targetUserName: widget.userName,
                            initialTab: 'following',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add, size: 16),
                    label: const Text('Following'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3498DB),
                      side: const BorderSide(color: Color(0xFF3498DB)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

}
