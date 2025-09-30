import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_analytics_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/error_handler.dart';

class AdvancedAnalyticsScreen extends StatefulWidget {
  const AdvancedAnalyticsScreen({super.key});

  @override
  State<AdvancedAnalyticsScreen> createState() => _AdvancedAnalyticsScreenState();
}

class _AdvancedAnalyticsScreenState extends State<AdvancedAnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalytics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final analyticsProvider = Provider.of<StudyAnalyticsProvider>(context, listen: false);

    if (userProvider.isLoggedIn && userProvider.currentUser != null) {
      await analyticsProvider.refreshAllAnalytics(
        userProvider.currentUser!.userName,
        userProvider.currentUser!.targetLanguage ?? 'English',
        level: userProvider.currentUser!.userLevel,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<StudyAnalyticsProvider, UserProvider>(
      builder: (context, analyticsProvider, userProvider, child) {
        if (!userProvider.isLoggedIn) {
          return _buildLoginPrompt();
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: const Text(
              'Advanced Analytics',
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
                Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
                Tab(text: 'Progress', icon: Icon(Icons.trending_up)),
                Tab(text: 'Streaks', icon: Icon(Icons.local_fire_department)),
                Tab(text: 'Difficulty', icon: Icon(Icons.psychology)),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(analyticsProvider),
              _buildProgressTab(analyticsProvider),
              _buildStreaksTab(analyticsProvider),
              _buildDifficultyTab(analyticsProvider),
            ],
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
          'Advanced Analytics',
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
                  Icons.analytics_outlined,
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
                'Login to view detailed analytics about your learning journey.',
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

  Widget _buildOverviewTab(StudyAnalyticsProvider analyticsProvider) {
    if (analyticsProvider.isLoadingInsights) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3498DB),
        ),
      );
    }

    if (analyticsProvider.insightsError != null) {
      return ErrorHandler.buildErrorWidget(
        analyticsProvider.insightsError!,
        () => _loadAnalytics(),
        retryText: 'Refresh Analytics',
      );
    }

    final insights = analyticsProvider.studyInsights;
    if (insights == null) {
      return _buildEmptyState('No analytics data available');
    }

    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      color: const Color(0xFF3498DB),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildOverviewStats(insights),
            const SizedBox(height: 24),
            _buildLearningMetrics(insights),
            const SizedBox(height: 24),
            _buildRecentActivity(insights),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab(StudyAnalyticsProvider analyticsProvider) {
    if (analyticsProvider.isLoadingProgress) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3498DB),
        ),
      );
    }

    if (analyticsProvider.progressError != null) {
      return ErrorHandler.buildErrorWidget(
        analyticsProvider.progressError!,
        () => _loadAnalytics(),
        retryText: 'Refresh Progress',
      );
    }

    final progress = analyticsProvider.studyProgress;
    if (progress == null) {
      return _buildEmptyState('No progress data available');
    }

    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      color: const Color(0xFF3498DB),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProgressChart(progress),
            const SizedBox(height: 24),
            _buildProgressMetrics(progress),
          ],
        ),
      ),
    );
  }

  Widget _buildStreaksTab(StudyAnalyticsProvider analyticsProvider) {
    if (analyticsProvider.isLoadingStreaks) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3498DB),
        ),
      );
    }

    if (analyticsProvider.streaksError != null) {
      return ErrorHandler.buildErrorWidget(
        analyticsProvider.streaksError!,
        () => _loadAnalytics(),
        retryText: 'Refresh Streaks',
      );
    }

    final streaks = analyticsProvider.learningStreaks;
    if (streaks == null) {
      return _buildEmptyState('No streak data available');
    }

    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      color: const Color(0xFF3498DB),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStreakOverview(streaks),
            const SizedBox(height: 24),
            _buildStreakHistory(streaks),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyTab(StudyAnalyticsProvider analyticsProvider) {
    if (analyticsProvider.isLoadingDifficulty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3498DB),
        ),
      );
    }

    if (analyticsProvider.difficultyError != null) {
      return ErrorHandler.buildErrorWidget(
        analyticsProvider.difficultyError!,
        () => _loadAnalytics(),
        retryText: 'Refresh Difficulty',
      );
    }

    final difficulty = analyticsProvider.difficultyAnalysis;
    if (difficulty == null) {
      return _buildEmptyState('No difficulty data available');
    }

    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      color: const Color(0xFF3498DB),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDifficultyOverview(difficulty),
            const SizedBox(height: 24),
            _buildDifficultyBreakdown(difficulty),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: const Color(0xFFBDC3C7),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF7F8C8D),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStats(Map<String, dynamic> insights) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B59B6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.analytics,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            '${insights['words_studied_today'] ?? 0}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'Words Studied Today',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('This Week', '${insights['words_studied_this_week'] ?? 0}', Icons.calendar_today),
              _buildStatItem('Total', '${insights['total_words_studied'] ?? 0}', Icons.stars),
              _buildStatItem('Streak', '${insights['study_streak'] ?? 0} days', Icons.local_fire_department),
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

  Widget _buildLearningMetrics(Map<String, dynamic> insights) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            'Learning Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricRow('Global Rank', '#${insights['global_rank'] ?? 0}', Icons.emoji_events),
          const Divider(height: 24),
          _buildMetricRow('Level Rank', '#${insights['level_rank'] ?? 0}', Icons.trending_up),
          const Divider(height: 24),
          _buildMetricRow('Most Difficult Words', '${(insights['most_difficult_words'] as List?)?.length ?? 0}', Icons.warning),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF3498DB), size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3498DB),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(Map<String, dynamic> insights) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your learning activity will appear here as you study more words and complete lessons.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart(Map<String, dynamic> progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            'Learning Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Progress chart will be displayed here',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMetrics(Map<String, dynamic> progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            'Progress Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Detailed progress metrics will be displayed here',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakOverview(Map<String, dynamic> streaks) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            'Learning Streaks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Streak information will be displayed here',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakHistory(Map<String, dynamic> streaks) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            'Streak History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Historical streak data will be displayed here',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyOverview(Map<String, dynamic> difficulty) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            'Difficulty Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Difficulty analysis will be displayed here',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBreakdown(Map<String, dynamic> difficulty) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            'Difficulty Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Detailed difficulty breakdown will be displayed here',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }
}
