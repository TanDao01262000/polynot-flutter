import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/smart_feed_provider.dart';
import '../services/social_service.dart';
import '../models/social_models.dart';
import '../widgets/error_handler.dart';
import '../utils/date_utils.dart' as app_date_utils;
import 'create_post_screen.dart';
import 'privacy_settings_screen.dart';
import 'smart_filtering_screen.dart';
import 'user_profile_screen.dart';

class PersonalizedFeedScreen extends StatefulWidget {
  final bool shouldRefresh;
  final VoidCallback? onRefreshComplete;
  
  const PersonalizedFeedScreen({
    super.key,
    this.shouldRefresh = false,
    this.onRefreshComplete,
  });

  @override
  State<PersonalizedFeedScreen> createState() => _PersonalizedFeedScreenState();
}

class _PersonalizedFeedScreenState extends State<PersonalizedFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  List<SocialPost> _posts = [];
  List<ContentRecommendation> _recommendations = [];
  List<TrendingContent> _trendingContent = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPersonalizedFeed();
    });
  }

  @override
  void didUpdateWidget(PersonalizedFeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldRefresh && !oldWidget.shouldRefresh) {
      _loadPersonalizedFeed(refresh: true);
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
      _loadMorePersonalizedFeed();
    }
  }

  Future<void> _loadPersonalizedFeed({bool refresh = false}) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
      if (refresh) {
        _currentPage = 1;
        _hasMoreData = true;
        _posts.clear();
        _recommendations.clear();
        _trendingContent.clear();
      }
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final smartFeedProvider = Provider.of<SmartFeedProvider>(context, listen: false);
      
      if (userProvider.isLoggedIn && userProvider.currentUser != null) {
        // Try enhanced feed first
        try {
          final feedResponse = await SocialService.getEnhancedNewsFeed(
            userProvider.currentUser!.id,
            page: _currentPage,
            limit: 20,
            includeLevelPeers: smartFeedProvider.includeLevelPeers,
            includeLanguagePeers: smartFeedProvider.includeLanguagePeers,
            includeTrending: smartFeedProvider.includeTrending,
            personalizationScore: smartFeedProvider.personalizationScore,
            levelFilter: smartFeedProvider.selectedLevel,
            languageFilter: smartFeedProvider.selectedLanguage,
          );

          setState(() {
            _posts = feedResponse.posts;
            _recommendations = feedResponse.recommendations ?? [];
            _trendingContent = feedResponse.trendingContent ?? [];
            _hasMoreData = feedResponse.hasNext;
            _isLoading = false;
          });

          print('🎯 Enhanced personalized feed loaded: ${_posts.length} posts, ${_recommendations.length} recommendations, ${_trendingContent.length} trending items');
        } catch (enhancedError) {
          print('⚠️ Enhanced feed failed, falling back to basic feed: $enhancedError');
          
          // Fallback to basic feed
          final basicPosts = await SocialService.getNewsFeed(
            userProvider.currentUser!.id,
            page: _currentPage,
            limit: 20,
          );

          setState(() {
            _posts = basicPosts;
            _recommendations = [];
            _trendingContent = [];
            _hasMoreData = basicPosts.isNotEmpty;
            _isLoading = false;
          });

          print('🎯 Basic personalized feed loaded: ${_posts.length} posts');
        }
      }
    } catch (e) {
      print('Error loading personalized feed: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMorePersonalizedFeed() async {
    if (_isLoadingMore || !_hasMoreData) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final smartFeedProvider = Provider.of<SmartFeedProvider>(context, listen: false);
      
      if (userProvider.isLoggedIn && userProvider.currentUser != null) {
        final nextPage = _currentPage + 1;
        
        try {
          final feedResponse = await SocialService.getEnhancedNewsFeed(
            userProvider.currentUser!.id,
            page: nextPage,
            limit: 20,
            includeLevelPeers: smartFeedProvider.includeLevelPeers,
            includeLanguagePeers: smartFeedProvider.includeLanguagePeers,
            includeTrending: smartFeedProvider.includeTrending,
            personalizationScore: smartFeedProvider.personalizationScore,
            levelFilter: smartFeedProvider.selectedLevel,
            languageFilter: smartFeedProvider.selectedLanguage,
          );

          setState(() {
            _posts.addAll(feedResponse.posts);
            _currentPage = nextPage;
            _hasMoreData = feedResponse.hasNext;
            _isLoadingMore = false;
          });
        } catch (enhancedError) {
          print('⚠️ Enhanced feed pagination failed, falling back to basic: $enhancedError');
          
          // Fallback to basic feed pagination
          final basicPosts = await SocialService.getNewsFeed(
            userProvider.currentUser!.id,
            page: nextPage,
            limit: 20,
          );

          setState(() {
            _posts.addAll(basicPosts);
            _currentPage = nextPage;
            _hasMoreData = basicPosts.isNotEmpty;
            _isLoadingMore = false;
          });
        }
      }
    } catch (e) {
      print('Error loading more personalized feed: $e');
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
              'Personalized Feed',
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
                       icon: const Icon(
                         Icons.tune,
                         color: Color(0xFF3498DB),
                       ),
                       onPressed: () {
                         Navigator.push(
                           context,
                           MaterialPageRoute(
                             builder: (context) => SmartFilteringScreen(
                               onFiltersApplied: () {
                                 // Show loading indicator and refresh the feed when filters are applied
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   const SnackBar(
                                     content: Row(
                                       children: [
                                         SizedBox(
                                           width: 16,
                                           height: 16,
                                           child: CircularProgressIndicator(
                                             strokeWidth: 2,
                                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                           ),
                                         ),
                                         SizedBox(width: 12),
                                         Text('Refreshing feed with new filters...'),
                                       ],
                                     ),
                                     backgroundColor: Color(0xFF3498DB),
                                     duration: Duration(seconds: 2),
                                   ),
                                 );
                                 // Refresh the feed when filters are applied
                                 _loadPersonalizedFeed(refresh: true);
                               },
                             ),
                           ),
                         );
                       },
                       tooltip: 'Smart Filtering',
                     ),
              IconButton(
                icon: const Icon(
                  Icons.privacy_tip_outlined,
                  color: Color(0xFF3498DB),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacySettingsScreen(),
                    ),
                  );
                },
                tooltip: 'Privacy Settings',
              ),
            ],
          ),
          body: _buildFeedBody(),
        );
      },
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
                Icons.person_search,
                size: 64,
                color: Color(0xFF3498DB),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Personalized Feed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Login to see content tailored to your learning journey.',
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

  Widget _buildFeedBody() {
    if (_isLoading && _posts.isEmpty && _recommendations.isEmpty && _trendingContent.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3498DB),
        ),
      );
    }

    if (_error != null && _posts.isEmpty && _recommendations.isEmpty && _trendingContent.isEmpty) {
      return ErrorHandler.buildErrorWidget(
        _error!,
        () => _loadPersonalizedFeed(refresh: true),
        retryText: 'Refresh Feed',
      );
    }

    if (_posts.isEmpty && _recommendations.isEmpty && _trendingContent.isEmpty) {
      return _buildEmptyFeed();
    }

    return RefreshIndicator(
      onRefresh: () => _loadPersonalizedFeed(refresh: true),
      color: const Color(0xFF3498DB),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: _getTotalItemCount(),
        itemBuilder: (context, index) {
          return _buildFeedItemAtIndex(index);
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4FD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person_search,
                size: 64,
                color: Color(0xFF3498DB),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Personalized Content Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'We\'re learning about your preferences. Keep using the app and we\'ll personalize your feed!',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7F8C8D),
                height: 1.5,
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

  int _getTotalItemCount() {
    int count = 0;
    
    // Add trending content section
    if (_trendingContent.isNotEmpty) count += 1;
    
    // Add recommendations section  
    if (_recommendations.isNotEmpty) count += 1;
    
    // Add posts
    count += _posts.length;
    
    // Add loading indicator
    if (_isLoadingMore) count += 1;
    
    return count;
  }

  Widget _buildFeedItemAtIndex(int index) {
    int currentIndex = 0;
    
    // Trending content section
    if (_trendingContent.isNotEmpty) {
      if (index == currentIndex) {
        return _buildTrendingSection();
      }
      currentIndex++;
    }
    
    // Recommendations section
    if (_recommendations.isNotEmpty) {
      if (index == currentIndex) {
        return _buildRecommendationsSection();
      }
      currentIndex++;
    }
    
    // Posts
    final postIndex = index - currentIndex;
    if (postIndex < _posts.length) {
      return _buildPostItem(_posts[postIndex]);
    }
    
    // Loading indicator
    if (index == currentIndex + _posts.length && _isLoadingMore) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(
            color: Color(0xFF3498DB),
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildTrendingSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: Color(0xFF3498DB),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Trending',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _trendingContent.length,
              itemBuilder: (context, index) {
                final trending = _trendingContent[index];
                return _buildTrendingItem(trending);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF3498DB),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Recommended for You',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
          ..._recommendations.map((rec) => _buildRecommendationItem(rec)),
        ],
      ),
    );
  }

  Widget _buildTrendingItem(TrendingContent trending) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3498DB).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trending.content,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${trending.language} • ${trending.level}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: Color(0xFF3498DB),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${(trending.popularityScore * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF3498DB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(ContentRecommendation recommendation) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3498DB).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getContentTypeIcon(recommendation.contentType),
                  color: const Color(0xFF3498DB),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      recommendation.reason,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(recommendation.relevanceScore * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendation.content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2C3E50),
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(SocialPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3498DB).withOpacity(0.2),
          width: 1,
        ),
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
            _buildPostHeader(post),
            const SizedBox(height: 12),
            _buildPostContent(post),
            const SizedBox(height: 12),
            _buildPostActions(post),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(SocialPost post) {
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
              GestureDetector(
                onTap: () => _navigateToUserProfile(post),
                child: Text(
                  post.userName.isNotEmpty ? post.userName : 'Unknown User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3498DB),
                  ),
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

  Widget _buildPostContent(SocialPost post) {
    return Text(
      post.content,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF2C3E50),
        height: 1.4,
      ),
    );
  }

  Widget _buildPostActions(SocialPost post) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final isCurrentUserPost = userProvider.isLoggedIn && 
            userProvider.currentUser?.userName == post.userName;
        
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
            const Spacer(),
            // Edit and Delete buttons for current user's posts
            if (isCurrentUserPost) ...[
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF3498DB),
                  size: 20,
                ),
                onPressed: () => _editPost(post),
                tooltip: 'Edit Post',
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFE74C3C),
                  size: 20,
                ),
                onPressed: () => _deletePost(post),
                tooltip: 'Delete Post',
              ),
            ],
          ],
        );
      },
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
        userProvider.currentUser!.userName, // Changed from userId to userName
      );

      // Update the post in the local list
      setState(() {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = SocialPost(
            id: post.id,
            userId: post.userId,
            userName: post.userName,
            title: post.title,
            content: post.content,
            postType: post.postType,
            visibility: post.visibility,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            likesCount: result['liked'] == true 
                ? post.likesCount + 1 
                : post.likesCount - 1,
            commentsCount: post.commentsCount,
            sharesCount: post.sharesCount,
            pointsEarned: post.pointsEarned,
            isLiked: result['liked'] == true,
            metadata: post.metadata,
          );
        }
      });

      // Show success message
      final action = result['liked'] == true ? 'liked ❤️' : 'undone 💔';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post $action'),
          backgroundColor: const Color(0xFF27AE60),
          duration: const Duration(seconds: 1),
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
    return app_date_utils.DateUtils.formatDate(timestamp);
  }

  IconData _getContentTypeIcon(String? contentType) {
    switch (contentType) {
      case 'vocabulary':
        return Icons.book;
      case 'learning_tip':
        return Icons.lightbulb_outline;
      case 'achievement':
        return Icons.emoji_events;
      case 'progress':
        return Icons.trending_up;
      default:
        return Icons.article_outlined;
    }
  }

  Future<void> _editPost(SocialPost post) async {
    // Navigate to edit post screen with pre-filled data
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(
          editPost: post,
        ),
      ),
    );

    // If the post was successfully updated, refresh the feed
    if (result == true) {
      _loadPersonalizedFeed(refresh: true);
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
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3498DB),
              ),
            ),
          );

          // Delete the post
          final success = await SocialService.deletePost(
            post.id,
            userProvider.currentUser!.userName,
          );

          // Hide loading indicator
          if (mounted) Navigator.pop(context);

          if (success) {
            // Remove the post from the local list
            setState(() {
              _posts.removeWhere((p) => p.id == post.id);
            });

            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post deleted successfully'),
                  backgroundColor: Color(0xFF27AE60),
                ),
              );
            }
          } else {
            throw Exception('Failed to delete post');
          }
        }
      } catch (e) {
        // Hide loading indicator if still showing
        if (mounted) Navigator.pop(context);
        
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete post: $e'),
              backgroundColor: const Color(0xFFE74C3C),
            ),
          );
        }
      }
    }
  }

  void _navigateToUserProfile(SocialPost post) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn || userProvider.currentUser == null) {
      return;
    }

    final isOwnProfile = post.userName == userProvider.currentUser!.userName;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          targetUserName: isOwnProfile ? null : post.userName,
          isViewingOtherProfile: !isOwnProfile,
        ),
      ),
    );
  }

}
