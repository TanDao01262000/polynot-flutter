import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/study_together_service.dart';
import '../services/social_service.dart';
import '../services/vocabulary_detail_service.dart';
import '../models/study_together_models.dart';
import '../models/vocabulary_item.dart';
import '../widgets/vocabulary_interaction_card.dart';
import '../widgets/vocabulary_discovery_simple_card.dart';
import '../widgets/vocabulary_filter_widget.dart';
import '../utils/date_utils.dart' as app_date_utils;
import 'user_profile_screen.dart';

class StudyTogetherScreen extends StatefulWidget {
  final bool shouldRefresh;
  final VoidCallback? onRefreshComplete;

  const StudyTogetherScreen({
    super.key,
    this.shouldRefresh = false,
    this.onRefreshComplete,
  });

  @override
  State<StudyTogetherScreen> createState() => _StudyTogetherScreenState();
}

class _StudyTogetherScreenState extends State<StudyTogetherScreen> {
  StudyTogetherResponse? _data;
  bool _isLoading = false;
  String? _error;
  final StudyTogetherService _service = StudyTogetherService();
  
  // Vocabulary details state
  bool _isLoadingVocabulary = false;
  
  // Filter state
  Map<String, String> _currentFilters = {};
  List<String> _availableFriends = [];
  Map<String, String> _friendNameToIdMap = {}; // Map username to user_id
  
  // Vocabulary discoveries state
  List<VocabularyDiscovery> _vocabularyDiscoveries = [];
  bool _hasMoreVocabulary = true;
  bool _isLoadingMoreVocabulary = false;
  int _currentVocabularyPage = 1;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  void didUpdateWidget(StudyTogetherScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldRefresh && !oldWidget.shouldRefresh) {
      _loadContent();
    }
  }

  Future<void> _loadContent() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn || userProvider.currentUser == null) {
      return;
    }

    print('🎯 StudyTogetherScreen: Loading content for user: ${userProvider.currentUser!.id}');

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🎯 StudyTogetherScreen: Calling StudyTogetherService.getStudyTogetherContent');
      final data = await _service.getStudyTogetherContent(userProvider.currentUser!.id);
      print('🎯 StudyTogetherScreen: Successfully loaded data: ${data.totalActivities} activities, ${data.friendsCount} friends');
      
      setState(() {
        _data = data;
        _isLoading = false;
      });
      
      // Extract available friends for filtering
      _extractAvailableFriends();
      
      // Automatically load vocabulary discoveries
      _loadVocabularyDiscoveries();
      
      // Call refresh complete callback
      widget.onRefreshComplete?.call();
    } catch (e) {
      print('🎯 StudyTogetherScreen: Error loading study together content: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      // Call refresh complete callback
      widget.onRefreshComplete?.call();
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
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF3498DB)),
            SizedBox(height: 16),
            Text(
              "Loading learning content from friends...",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7F8C8D),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFE74C3C),
              ),
              const SizedBox(height: 16),
              const Text(
                "Unable to Load Content",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7F8C8D),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadContent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Try Again"),
              ),
            ],
          ),
        ),
      );
    }

    if (_data == null || _data!.totalActivities == 0) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadContent,
      color: const Color(0xFF3498DB),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsHeader(),
          const SizedBox(height: 16),
          _buildTrendingVocabularySection(),
          const SizedBox(height: 16),
          _buildFriendsVocabularySection(),
          const SizedBox(height: 16),
          _buildProgressUpdatesSection(),
          const SizedBox(height: 16),
          _buildStudyActivitiesSection(),
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
            const Icon(
              Icons.people_outline,
              size: 80,
              color: Color(0xFFBDC3C7),
            ),
            const SizedBox(height: 24),
            const Text(
              "No Learning Content Yet",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Follow some people to see their learning content and discover new vocabulary!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7F8C8D),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/user-discovery'),
              icon: const Icon(Icons.search, size: 20),
              label: const Text("Find People to Follow"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem("Friends", "${_data!.friendsCount}", Icons.people, const Color(0xFF3498DB)),
            _buildStatItem("Activities", "${_data!.totalActivities}", Icons.dynamic_feed, const Color(0xFF27AE60)),
            _buildStatItem("Trending", "${_data!.trendingVocabulary.length}", Icons.trending_up, const Color(0xFFF39C12)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7F8C8D),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingVocabularySection() {
    if (_data!.trendingVocabulary.isEmpty) return const SizedBox.shrink();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Color(0xFFF39C12)),
                const SizedBox(width: 8),
                const Text(
                  "Trending Words",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._data!.trendingVocabulary.map((word) => _buildTrendingWordCard(word)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingWordCard(TrendingWord word) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getDifficultyColor(word.level),
          child: Text(
            word.level,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          word.word,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          "${word.studyCount} friends studying • ${word.language}",
          style: const TextStyle(color: Color(0xFF7F8C8D)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () => _bookmarkWord(word.word),
              tooltip: "Bookmark word",
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () => _likeWord(word.word),
              tooltip: "Like word",
            ),
          ],
        ),
        onTap: () => _showWordDetails(word),
      ),
    );
  }

  Widget _buildFriendsVocabularySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: Color(0xFF3498DB)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Vocabulary from Friends",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                // Filter button
                IconButton(
                  onPressed: _showFilterDialog,
                  icon: Icon(
                    Icons.filter_list,
                    color: _currentFilters.isNotEmpty ? Color(0xFF3498DB) : Colors.grey.shade600,
                  ),
                  tooltip: 'Filter vocabulary',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Discover and save vocabulary words from people you follow",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7F8C8D),
                fontStyle: FontStyle.italic,
              ),
            ),
            
            // Show active filters
            if (_currentFilters.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildActiveFiltersChips(),
            ],
            
            const SizedBox(height: 16),
            
            // Refresh and Clear buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingVocabulary ? null : _loadVocabularyDiscoveries,
                    icon: _isLoadingVocabulary 
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.refresh, size: 18),
                    label: Text(_isLoadingVocabulary 
                        ? 'Loading...' 
                        : 'Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                if (_currentFilters.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE74C3C),
                      side: const BorderSide(color: Color(0xFFE74C3C)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Vocabulary discoveries list
            if (_isLoadingVocabulary) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: Color(0xFF3498DB)),
                ),
              ),
            ] else if (_vocabularyDiscoveries.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.book,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No vocabulary found from your friends yet.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try following more people or adjust your filters!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Text(
                '${_vocabularyDiscoveries.length} vocabulary items from your friends:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 400, // Fixed height for the vocabulary list
                child: ListView.builder(
                  itemCount: _vocabularyDiscoveries.length + (_hasMoreVocabulary ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show "Load More" button as the last item
                    if (index == _vocabularyDiscoveries.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: _isLoadingMoreVocabulary
                              ? const CircularProgressIndicator(color: Color(0xFF3498DB))
                              : ElevatedButton.icon(
                                  onPressed: _loadMoreVocabulary,
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Load More'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3498DB),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                        ),
                      );
                    }
                    
                    final discovery = _vocabularyDiscoveries[index];
                    return VocabularyDiscoverySimpleCard(
                      discovery: discovery,
                      onTap: () => _showVocabularyDetailFromDiscovery(discovery),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressUpdatesSection() {
    if (_data!.progressUpdates.isEmpty) return const SizedBox.shrink();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFF39C12)),
                const SizedBox(width: 8),
                const Text(
                  "Friends' Achievements",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._data!.progressUpdates.map((update) => _buildProgressUpdateCard(update)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressUpdateCard(ProgressUpdate update) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundImage: update.authorAvatar != null 
            ? NetworkImage(update.authorAvatar!) 
            : null,
          child: update.authorAvatar == null 
            ? Text(
                update.authorName.isNotEmpty ? update.authorName[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ) 
            : null,
        ),
        title: Text(
          update.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          update.description,
          style: const TextStyle(color: Color(0xFF7F8C8D)),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF39C12).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${update.points} pts",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF39C12),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.favorite_border, size: 16, color: Color(0xFF7F8C8D)),
          ],
        ),
        onTap: () => _showAchievementDetails(update),
      ),
    );
  }

  Widget _buildStudyActivitiesSection() {
    if (_data!.studyActivities.isEmpty) return const SizedBox.shrink();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dynamic_feed, color: Color(0xFF27AE60)),
                const SizedBox(width: 8),
                const Text(
                  "Recent Activities",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._data!.studyActivities.map((activity) => _buildActivityCard(activity)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(StudyActivity activity) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundImage: activity.authorAvatar != null 
            ? NetworkImage(activity.authorAvatar!) 
            : null,
          child: activity.authorAvatar == null 
            ? Text(
                activity.authorName.isNotEmpty ? activity.authorName[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ) 
            : null,
        ),
        title: Text(
          activity.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.content,
              style: const TextStyle(color: Color(0xFF7F8C8D)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(activity.createdAt.toIso8601String()),
              style: const TextStyle(
                color: Color(0xFF95A5A6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () => _showActivityDetails(activity),
      ),
    );
  }

  Color _getDifficultyColor(String level) {
    switch (level) {
      case 'A1':
      case 'A2':
        return const Color(0xFF27AE60);
      case 'B1':
      case 'B2':
        return const Color(0xFFF39C12);
      case 'C1':
      case 'C2':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF7F8C8D);
    }
  }

  String _formatDate(String dateString) {
    try {
      DateTime date;
      
      // Check if it's an ISO 8601 string (contains T and Z or +)
      if (dateString.contains('T') && (dateString.contains('Z') || dateString.contains('+'))) {
        date = DateTime.parse(dateString);
      } else {
        // Try to parse as relative time string using the date utils
        date = app_date_utils.DateUtils.parseDate(dateString);
      }
      
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return "${difference.inDays}d ago";
      } else if (difference.inHours > 0) {
        return "${difference.inHours}h ago";
      } else if (difference.inMinutes > 0) {
        return "${difference.inMinutes}m ago";
      } else {
        return "Just now";
      }
    } catch (e) {
      print('❌ Error formatting date: $dateString - $e');
      return "Recently";
    }
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 80,
              color: Color(0xFFBDC3C7),
            ),
            const SizedBox(height: 16),
            const Text(
              'Login to View Study Together',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7F8C8D),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please log in to see learning content from your friends.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF95A5A6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bookmarkWord(String word) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isLoggedIn && userProvider.currentUser != null) {
        final success = await _service.bookmarkVocabulary(userProvider.currentUser!.id, word);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("'$word' added to your vocabulary list!"),
                backgroundColor: const Color(0xFF27AE60),
                action: SnackBarAction(
                  label: "View",
                  textColor: Colors.white,
                  onPressed: () {
                    // Navigate to vocabulary list
                    Navigator.pushNamed(context, '/vocabulary');
                  },
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to bookmark word: $e"),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  void _likeWord(String word) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Liked '$word'!"),
        backgroundColor: const Color(0xFFE91E63),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showWordDetails(TrendingWord word) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getDifficultyColor(word.level),
              child: Text(
                word.level,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                word.word,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Language: ${word.language}"),
            Text("Level: ${word.level}"),
            Text("Studied by: ${word.studyCount} friends"),
            const SizedBox(height: 16),
            const Text(
              "Recent studiers:",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...word.recentStudiers.take(3).map((studier) => 
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundImage: studier.avatarUrl != null 
                    ? NetworkImage(studier.avatarUrl!) 
                    : null,
                  child: studier.avatarUrl == null 
                    ? Text(
                        studier.userName.isNotEmpty ? studier.userName[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 12),
                      ) 
                    : null,
                ),
                title: GestureDetector(
                  onTap: () => _navigateToUserProfile(studier.userName),
                  child: Text(
                    studier.userName, 
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3498DB),
                    ),
                  ),
                ),
                subtitle: Text(_formatDate(studier.studiedAt.toIso8601String()), style: const TextStyle(fontSize: 12)),
              ),
            ).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _bookmarkWord(word.word);
            },
            icon: const Icon(Icons.bookmark, size: 16),
            label: const Text("Add to My List"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showAchievementDetails(ProgressUpdate update) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(update.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(child: Text(update.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(update.description),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF39C12).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, color: Color(0xFFF39C12)),
                  const SizedBox(width: 8),
                  Text("Points earned: ${update.points}"),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _navigateToUserProfile(update.authorName),
              child: Text(
                "Achieved by: ${update.authorName}",
                style: const TextStyle(color: Color(0xFF3498DB)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to user's profile
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              foregroundColor: Colors.white,
            ),
            child: const Text("View Profile"),
          ),
        ],
      ),
    );
  }

  void _showActivityDetails(StudyActivity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity.content),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Color(0xFF3498DB)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _navigateToUserProfile(activity.authorName),
                    child: Text(
                      "By: ${activity.authorName}",
                      style: const TextStyle(color: Color(0xFF3498DB)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text("Type: ${activity.activityType}"),
            Text("Posted: ${_formatDate(activity.createdAt.toIso8601String())}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to full post
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              foregroundColor: Colors.white,
            ),
            child: const Text("View Post"),
          ),
        ],
      ),
    );
  }

  // Automatically load vocabulary discoveries when the screen loads (first page only)
  Future<void> _loadVocabularyDiscoveries({bool reset = true}) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (!userProvider.isLoggedIn || userProvider.currentUser == null) {
        return;
      }

      print('📚 StudyTogetherScreen: Loading vocabulary discoveries (${reset ? "first page" : "next page"})...');
      
      setState(() {
        if (reset) {
          _isLoadingVocabulary = true;
          _vocabularyDiscoveries = [];
          _currentVocabularyPage = 1;
        } else {
          _isLoadingMoreVocabulary = true;
          _currentVocabularyPage++;
        }
      });

      // Get list of vocabulary discoveries from friends with filters (load 10 initially)
      final limit = 10; // Load 10 at a time
      
      // Convert usernames to user IDs for the user filter
      List<String>? userFilterIds;
      if (_currentFilters['user_filter'] != null) {
        final selectedUsernames = _currentFilters['user_filter']!.split(',');
        userFilterIds = selectedUsernames
            .map((username) => _friendNameToIdMap[username])
            .where((id) => id != null)
            .cast<String>()
            .toList();
        
        print('👥 StudyTogetherScreen: Converting usernames to IDs: $selectedUsernames -> $userFilterIds');
      }
      
      final followingResponse = await _service.getLearningDiscovery(
        userProvider.currentUser!.id,
        contentType: 'vocabulary',
        limit: limit,
        page: _currentVocabularyPage,
        levelFilter: _currentFilters['level_filter'],
        userFilter: userFilterIds,
        languageFilter: _currentFilters['language_filter'],
      );

      setState(() {
        if (reset) {
          _vocabularyDiscoveries = followingResponse.discoveryContent.vocabularyDiscoveries;
          _isLoadingVocabulary = false;
        } else {
          _vocabularyDiscoveries.addAll(followingResponse.discoveryContent.vocabularyDiscoveries);
          _isLoadingMoreVocabulary = false;
        }
        
        // Check if we have more items to load
        _hasMoreVocabulary = followingResponse.discoveryContent.vocabularyDiscoveries.length == limit;
      });

      print('📚 StudyTogetherScreen: Loaded ${followingResponse.discoveryContent.vocabularyDiscoveries.length} vocabulary discoveries (total: ${_vocabularyDiscoveries.length})');
    } catch (e) {
      print('📚 StudyTogetherScreen: Error loading vocabulary discoveries: $e');
      setState(() {
        _isLoadingVocabulary = false;
        _isLoadingMoreVocabulary = false;
      });
    }
  }

  // Load more vocabulary discoveries (pagination)
  Future<void> _loadMoreVocabulary() async {
    if (_isLoadingMoreVocabulary || !_hasMoreVocabulary) return;
    await _loadVocabularyDiscoveries(reset: false);
  }




  // Fetch full vocabulary details only when user clicks on a discovery card (lazy loading)
  void _showVocabularyDetailFromDiscovery(VocabularyDiscovery discovery) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF3498DB)),
            const SizedBox(height: 16),
            Text('Loading full details for "${discovery.word}"...'),
          ],
        ),
      ),
    );

    try {
      // Get user provider for authentication
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Fetch full vocabulary details only for this specific item
      final vocabularyItem = await VocabularyDetailService.getVocabularyDetail(
        discovery.vocabEntryId,
        userProvider: userProvider,
      );

      // Close loading dialog
      Navigator.pop(context);

      if (vocabularyItem != null) {
        // Show full vocabulary detail dialog
        _showVocabularyDetailDialog(vocabularyItem);
      } else {
        // Show error if vocabulary not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load full details for "${discovery.word}". The vocabulary entry might not exist in the system.'),
            backgroundColor: const Color(0xFFF39C12),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show detailed vocabulary dialog when simple card is clicked
  void _showVocabularyDetailDialog(VocabularyItem vocabularyItem) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          width: MediaQuery.of(context).size.width * 0.95,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF3498DB)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Vocabulary Details",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Full vocabulary interaction card
              Expanded(
                child: SingleChildScrollView(
                  child: VocabularyInteractionCard(
                    item: vocabularyItem,
                    onFavorite: () => _handleFavorite(vocabularyItem),
                    onHide: () => _handleHide(vocabularyItem),
                    onReview: () => _handleReview(vocabularyItem),
                    onAddNote: (note) => _handleAddNote(vocabularyItem, note),
                    onRate: (rating) => _handleRate(vocabularyItem, rating),
                    onAddToList: (listId) => _handleAddToList(vocabularyItem, listId),
                    personalLists: [], // Empty for now, could be populated later
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Handler methods for vocabulary interactions
  void _handleFavorite(VocabularyItem vocabularyItem) {
    // TODO: Implement favorite functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${vocabularyItem.isFavorite ? "Removed from" : "Added to"} favorites: ${vocabularyItem.word}'),
        backgroundColor: const Color(0xFF3498DB),
      ),
    );
  }

  void _handleHide(VocabularyItem vocabularyItem) {
    // TODO: Implement hide functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${vocabularyItem.isHidden ? "Shown" : "Hidden"}: ${vocabularyItem.word}'),
        backgroundColor: const Color(0xFFF39C12),
      ),
    );
  }

  void _handleReview(VocabularyItem vocabularyItem) {
    // TODO: Implement review functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${vocabularyItem.lastReviewed != null ? "Unmarked as reviewed" : "Marked as reviewed"}: ${vocabularyItem.word}'),
        backgroundColor: const Color(0xFF27AE60),
      ),
    );
  }

  void _handleAddNote(VocabularyItem vocabularyItem, String note) {
    // TODO: Implement add note functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Note added to: ${vocabularyItem.word}'),
        backgroundColor: const Color(0xFF3498DB),
      ),
    );
  }

  void _handleRate(VocabularyItem vocabularyItem, int rating) {
    // TODO: Implement rating functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rated ${vocabularyItem.word} as $rating stars'),
        backgroundColor: const Color(0xFFF39C12),
      ),
    );
  }

  void _handleAddToList(VocabularyItem vocabularyItem, String listId) {
    // TODO: Implement add to list functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${vocabularyItem.word} to list'),
        backgroundColor: const Color(0xFF27AE60),
      ),
    );
  }

  // Filter functionality
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Filter widget
            Expanded(
              child: VocabularyFilterWidget(
                onFilterChanged: _onFiltersChanged,
                availableUsers: _availableFriends,
                initialFilters: _currentFilters,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onFiltersChanged(Map<String, String> filters) {
    setState(() {
      _currentFilters = filters;
      _vocabularyDiscoveries = [];
      _hasMoreVocabulary = true;
      _currentVocabularyPage = 1;
    });
    
    // Reload vocabulary with new filters
    _loadVocabularyDiscoveries();
    
    // Show feedback about applied filters
    if (filters.isNotEmpty) {
      final filterCount = filters.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Applied $filterCount filter${filterCount > 1 ? 's' : ''}'),
          backgroundColor: const Color(0xFF27AE60),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _clearFilters() {
    setState(() {
      _currentFilters = {};
      _vocabularyDiscoveries = [];
      _hasMoreVocabulary = true;
      _currentVocabularyPage = 1;
    });
    
    // Reload vocabulary with cleared filters
    _loadVocabularyDiscoveries();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters cleared'),
        backgroundColor: Color(0xFF3498DB),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: _currentFilters.entries.map((entry) {
        return Chip(
          label: Text(_getFilterDisplayText(entry.key, entry.value)),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() {
              _currentFilters.remove(entry.key);
            });
          },
          backgroundColor: const Color(0xFF3498DB).withOpacity(0.1),
          labelStyle: const TextStyle(
            color: Color(0xFF3498DB),
            fontSize: 12,
          ),
        );
      }).toList(),
    );
  }

  String _getFilterDisplayText(String key, String value) {
    switch (key) {
      case 'level_filter':
        return 'Level: ${_getLevelDisplayName(value)}';
      case 'user_filter':
        final users = value.split(',');
        if (users.length == 1) {
          return 'From: ${users.first}';
        } else {
          return 'From: ${users.length} friends';
        }
      case 'language_filter':
        return 'Language: $value';
      default:
        return '$key: $value';
    }
  }

  String _getLevelDisplayName(String level) {
    switch (level) {
      case 'exact': return 'My Level';
      case 'flexible': return 'Flexible';
      case 'all': return 'All Levels';
      default: return level;
    }
  }


  void _extractAvailableFriends() async {
    if (_data == null) return;
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (!userProvider.isLoggedIn || userProvider.currentUser == null) {
        return;
      }

      print('👥 StudyTogetherScreen: Fetching friends list for filtering...');
      
      // Get the actual friends list from the API
      final following = await SocialService.getFollowing(userProvider.currentUser!.id);
      final friendsList = List<Map<String, dynamic>>.from(following['following'] ?? []);
      
      // Extract user names and IDs from the friends list
      final friends = <String>{};
      final friendNameToIdMap = <String, String>{};
      
      for (final friend in friendsList) {
        final userName = friend['user_name'] as String?;
        final userId = friend['user_id'] as String?;
        
        if (userName != null && userName.isNotEmpty && userId != null) {
          friends.add(userName);
          friendNameToIdMap[userName] = userId;
        }
      }
      
      // Also add friends from the study together data as fallback
      for (final activity in _data!.studyActivities) {
        if (activity.authorName.isNotEmpty && !friends.contains(activity.authorName)) {
          friends.add(activity.authorName);
          // We'll need to get the user_id for these users
        }
      }
      
      for (final update in _data!.progressUpdates) {
        if (update.authorName.isNotEmpty && !friends.contains(update.authorName)) {
          friends.add(update.authorName);
          // We'll need to get the user_id for these users
        }
      }
      
      setState(() {
        _availableFriends = friends.toList()..sort();
        _friendNameToIdMap = friendNameToIdMap;
      });
      
      print('👥 StudyTogetherScreen: Loaded ${_availableFriends.length} available friends: $_availableFriends');
      print('👥 StudyTogetherScreen: Friend ID mapping: $_friendNameToIdMap');
    } catch (e) {
      print('👥 StudyTogetherScreen: Error loading friends list: $e');
      
      // Fallback: extract from study together data only
      final friends = <String>{};
      
      for (final activity in _data!.studyActivities) {
        if (activity.authorName.isNotEmpty) {
          friends.add(activity.authorName);
        }
      }
      
      for (final update in _data!.progressUpdates) {
        if (update.authorName.isNotEmpty) {
          friends.add(update.authorName);
        }
      }
      
      setState(() {
        _availableFriends = friends.toList()..sort();
      });
      
      print('👥 StudyTogetherScreen: Fallback - extracted ${_availableFriends.length} friends from study data');
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
}
