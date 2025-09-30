import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/social_service.dart';
import '../models/social_models.dart';
import '../widgets/error_handler.dart';
import 'create_post_screen.dart';
import 'post_comments_screen.dart';

class NewsFeedScreen extends StatefulWidget {
  final bool shouldRefresh;
  final VoidCallback? onRefreshComplete;
  
  const NewsFeedScreen({
    super.key,
    this.shouldRefresh = false,
    this.onRefreshComplete,
  });

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  List<SocialPost> _posts = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    print('📰 NewsFeedScreen: initState called');
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('📰 NewsFeedScreen: Loading feed...');
      _loadFeed();
    });
  }

  @override
  void didUpdateWidget(NewsFeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldRefresh && !oldWidget.shouldRefresh) {
      print('📰 NewsFeedScreen: Refresh requested, reloading feed...');
      _loadFeed();
      widget.onRefreshComplete?.call();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreFeed();
    }
  }

  Future<void> _loadFeed() async {
    if (_isLoading) {
      print('📰 NewsFeedScreen: Already loading, skipping...');
      return;
    }
    
    print('📰 NewsFeedScreen: Starting to load feed...');
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      _hasMoreData = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isLoggedIn && userProvider.currentUser != null) {
        print('📰 NewsFeedScreen: Using user ID: ${userProvider.currentUser!.id}');
        print('📰 NewsFeedScreen: User name: ${userProvider.currentUser!.userName}');
        print('📰 NewsFeedScreen: User ID type: ${userProvider.currentUser!.id.runtimeType}');
        final posts = await SocialService.getNewsFeed(
          userProvider.currentUser!.id,
          page: _currentPage,
          limit: 20,
        );
        
        print('📰 NewsFeedScreen: Loaded ${posts.length} posts');
        print('📰 NewsFeedScreen: Posts: ${posts.map((p) => p.content).toList()}');
        
        // If this is a refresh and we have no posts, add a temporary mock post for testing
        if (widget.shouldRefresh && posts.isEmpty) {
          print('📰 NewsFeedScreen: Adding mock post for testing refresh...');
          final mockPost = SocialPost(
            id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
            userName: userProvider.currentUser!.userName,
            title: 'Test Post',
            content: 'Mock post created at ${DateTime.now().toString()}',
            postType: 'learning_tip',
            visibility: 'public',
            likesCount: 0,
            commentsCount: 0,
            sharesCount: 0,
            pointsEarned: 10,
            isLiked: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            metadata: {'category': 'test'},
          );
          posts.add(mockPost);
        }
        
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading feed: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreFeed() async {
    if (_isLoadingMore || !_hasMoreData) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isLoggedIn && userProvider.currentUser != null) {
        final nextPage = _currentPage + 1;
        print('📰 NewsFeedScreen: Loading more feed for user ID: ${userProvider.currentUser!.id}');
        final newPosts = await SocialService.getNewsFeed(
          userProvider.currentUser!.id,
          page: nextPage,
          limit: 20,
        );
        
        setState(() {
          _posts.addAll(newPosts);
          _currentPage = nextPage;
          _hasMoreData = newPosts.isNotEmpty;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Error loading more feed: $e');
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.isLoggedIn) {
          return _buildLoginPrompt();
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: const Text(
              'News Feed',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF3498DB)),
                onPressed: () => _loadFeed(),
              ),
            ],
          ),
          body: _buildFeedBody(),
        );
      },
    );
  }

  Widget _buildLoginPrompt() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'News Feed',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
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
                  Icons.feed_outlined,
                  size: 64,
                  color: Color(0xFF3498DB),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Stay Connected!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Login to see personalized content from your learning community.',
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

  Widget _buildFeedBody() {
    if (_isLoading && _posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3498DB),
        ),
      );
    }

    if (_error != null && _posts.isEmpty) {
      return ErrorHandler.buildErrorWidget(
        _error!,
        () => _loadFeed(),
        retryText: 'Refresh Feed',
      );
    }

    if (_posts.isEmpty) {
      return _buildEmptyFeed();
    }

    return RefreshIndicator(
      onRefresh: _loadFeed,
      color: const Color(0xFF3498DB),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Add bottom padding for FAB
        itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _posts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: Color(0xFF3498DB),
                ),
              ),
            );
          }

          final post = _posts[index];
          return _buildFeedItem(post);
        },
      ),
    );
  }

  Widget _buildEmptyFeed() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.shouldRefresh)
              const CircularProgressIndicator(
                color: Color(0xFF3498DB),
              )
            else
              Icon(
                Icons.feed_outlined,
                size: 64,
                color: const Color(0xFFBDC3C7),
              ),
            const SizedBox(height: 16),
            Text(
              widget.shouldRefresh ? 'Refreshing Feed...' : 'No Posts Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: widget.shouldRefresh ? const Color(0xFF3498DB) : const Color(0xFF7F8C8D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.shouldRefresh 
                ? 'Looking for new posts...'
                : 'Be the first to share your learning journey!',
              style: TextStyle(
                fontSize: 14,
                color: widget.shouldRefresh ? const Color(0xFF3498DB) : const Color(0xFFBDC3C7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePostScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Post'),
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

  Widget _buildFeedItem(SocialPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeedItemHeader(post),
            const SizedBox(height: 12),
            _buildFeedItemContent(post),
            const SizedBox(height: 12),
            _buildFeedItemActions(post),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedItemHeader(SocialPost post) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF3498DB),
          child: Text(
            post.userName.isNotEmpty ? post.userName[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.userName.isNotEmpty ? post.userName : 'Unknown User',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                _formatTimestamp(post.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7F8C8D),
                ),
              ),
            ],
          ),
        ),
        Icon(
          _getPostTypeIcon(post.postType),
          color: const Color(0xFF3498DB),
          size: 20,
        ),
      ],
    );
  }

  Widget _buildFeedItemContent(SocialPost post) {
    return Text(
      post.content,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF2C3E50),
        height: 1.4,
      ),
    );
  }

  Widget _buildFeedItemActions(SocialPost post) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            post.isLiked ? Icons.favorite : Icons.favorite_border,
            color: post.isLiked ? Colors.red : const Color(0xFF7F8C8D),
            size: 20,
          ),
          onPressed: () => _toggleLike(post),
        ),
        Text(
          '${post.likesCount}',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7F8C8D),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: Icon(
            Icons.comment_outlined,
            color: const Color(0xFF7F8C8D),
            size: 20,
          ),
          onPressed: () => _showComments(post),
        ),
        Text(
          '${post.commentsCount}',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7F8C8D),
          ),
        ),
        const Spacer(),
        // Show edit/delete buttons only for user's own posts
        Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            if (userProvider.isLoggedIn && 
                userProvider.currentUser != null && 
                post.userName == userProvider.currentUser!.userName) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF3498DB),
                      size: 20,
                    ),
                    onPressed: () => _editPost(post),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFE74C3C),
                      size: 20,
                    ),
                    onPressed: () => _deletePost(post),
                  ),
                ],
              );
            }
            return IconButton(
              icon: const Icon(
                Icons.share_outlined,
                color: Color(0xFF7F8C8D),
                size: 20,
              ),
              onPressed: () {
                // TODO: Implement share functionality
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _toggleLike(SocialPost post) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (!userProvider.isLoggedIn || userProvider.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to like posts'),
            backgroundColor: Color(0xFFE74C3C),
          ),
        );
        return;
      }

      final result = await SocialService.toggleLike(
        post.id,
        userProvider.currentUser!.id,
      );

      // Update the post in the local list
      setState(() {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = SocialPost(
            id: post.id,
            userName: post.userName,
            postType: post.postType,
            title: post.title,
            content: post.content,
            visibility: post.visibility,
            likesCount: result['liked'] == true 
                ? post.likesCount + 1 
                : post.likesCount - 1,
            commentsCount: post.commentsCount,
            sharesCount: post.sharesCount,
            pointsEarned: post.pointsEarned,
            isLiked: result['liked'] == true,
            authorAvatar: post.authorAvatar,
            metadata: post.metadata,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Like toggled'),
          backgroundColor: result['liked'] == true 
              ? const Color(0xFFE74C3C) 
              : const Color(0xFF7F8C8D),
        ),
      );
    } catch (e) {
      print('Error toggling like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to like post: $e'),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
    }
  }

  Future<void> _editPost(SocialPost post) async {
    // For now, show a simple edit dialog
    final titleController = TextEditingController(text: post.title);
    final contentController = TextEditingController(text: post.content);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        if (userProvider.isLoggedIn && userProvider.currentUser != null) {
          await SocialService.updatePost(
            post.id,
            userProvider.currentUser!.userName,
            {
              'title': titleController.text.trim(),
              'content': contentController.text.trim(),
            },
          );
          
          // Refresh the feed to show updated post
          _loadFeed();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post updated successfully'),
              backgroundColor: Color(0xFF27AE60),
            ),
          );
        }
      } catch (e) {
        print('Error updating post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating post: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  Future<void> _deletePost(SocialPost post) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE74C3C),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        if (userProvider.isLoggedIn && userProvider.currentUser != null) {
          await SocialService.deletePost(post.id, userProvider.currentUser!.userName);
          
          // Remove post from local state
          setState(() {
            _posts.removeWhere((p) => p.id == post.id);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post deleted successfully'),
              backgroundColor: Color(0xFF27AE60),
            ),
          );
        }
      } catch (e) {
        print('Error deleting post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting post: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  void _showComments(SocialPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostCommentsScreen(post: post),
      ),
    );
  }

  IconData _getPostTypeIcon(String? postType) {
    switch (postType) {
      case 'learning_tip':
        return Icons.lightbulb_outline;
      case 'achievement':
        return Icons.emoji_events;
      case 'milestone':
        return Icons.flag;
      case 'challenge':
        return Icons.fitness_center;
      default:
        return Icons.article_outlined;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
