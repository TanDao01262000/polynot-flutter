import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/study_together_service.dart';
import '../models/study_together_models.dart';
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
                const Text(
                  "Vocabulary from Friends",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadFriendsVocabulary,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Load Friends\' Vocabulary'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Future<void> _loadFriendsVocabulary() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (!userProvider.isLoggedIn || userProvider.currentUser == null) {
        return;
      }

      print('📚 StudyTogetherScreen: Loading friends vocabulary...');
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF3498DB),
          ),
        ),
      );

      // Get list of following users first
      final followingResponse = await _service.getLearningDiscovery(
        userProvider.currentUser!.id,
        contentType: 'vocabulary',
        limit: 50,
      );

      // Close loading dialog
      Navigator.pop(context);

      if (followingResponse.discoveryContent.vocabularyDiscoveries.isNotEmpty) {
        _showFriendsVocabularyDialog(followingResponse.discoveryContent.vocabularyDiscoveries);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No vocabulary found from your friends yet. Try following more people!'),
            backgroundColor: Color(0xFFF39C12),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog if it's open
      print('📚 StudyTogetherScreen: Error loading friends vocabulary: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading friends vocabulary: $e'),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
    }
  }

  void _showFriendsVocabularyDialog(List<VocabularyDiscovery> vocabularyList) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
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
              Expanded(
                child: ListView.builder(
                  itemCount: vocabularyList.length,
                  itemBuilder: (context, index) {
                    final vocab = vocabularyList[index];
                    return _buildFriendVocabularyCard(vocab);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendVocabularyCard(VocabularyDiscovery vocab) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getDifficultyColor(vocab.level),
          child: Text(
            vocab.level,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          vocab.word,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vocab.context,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Color(0xFF7F8C8D),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            GestureDetector(
              onTap: () => _navigateToUserProfile(vocab.authorName),
              child: Text(
                "From: ${vocab.authorName}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF3498DB),
                ),
              ),
            ),
          ],
        ),
        trailing: ElevatedButton.icon(
          onPressed: () => _saveVocabularyToMyList(vocab),
          icon: const Icon(Icons.bookmark_add, size: 16),
          label: const Text('Save'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF27AE60),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            textStyle: const TextStyle(fontSize: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        onTap: () => _showVocabularyDetails(vocab),
      ),
    );
  }

  Future<void> _saveVocabularyToMyList(VocabularyDiscovery vocab) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (!userProvider.isLoggedIn || userProvider.currentUser == null) {
        return;
      }

      print('📚 StudyTogetherScreen: Saving vocabulary "${vocab.word}" to my list...');
      
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 16),
              Text('Saving vocabulary...'),
            ],
          ),
          backgroundColor: Color(0xFF3498DB),
        ),
      );

      // Call the bookmark vocabulary API
      final success = await _service.bookmarkVocabulary(
        userProvider.currentUser!.id,
        vocab.word,
        language: 'English', // Default language
      );

      // Hide loading
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ "${vocab.word}" saved to your vocabulary list!'),
            backgroundColor: const Color(0xFF27AE60),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to save "${vocab.word}". Please try again.'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      print('📚 StudyTogetherScreen: Error saving vocabulary: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving vocabulary: $e'),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
    }
  }

  void _showVocabularyDetails(VocabularyDiscovery vocab) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vocab.word),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Context: ${vocab.context}",
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            Text("Level: ${vocab.level}"),
            GestureDetector(
              onTap: () => _navigateToUserProfile(vocab.authorName),
              child: Text(
                "From: ${vocab.authorName}",
                style: const TextStyle(color: Color(0xFF3498DB)),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Save this word to your vocabulary list to study it later!",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
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
              _saveVocabularyToMyList(vocab);
            },
            icon: const Icon(Icons.bookmark_add),
            label: const Text("Save to My List"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
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
