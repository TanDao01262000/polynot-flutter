import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';

class FlashcardStatsScreen extends StatefulWidget {
  const FlashcardStatsScreen({super.key});

  @override
  State<FlashcardStatsScreen> createState() => _FlashcardStatsScreenState();
}

class _FlashcardStatsScreenState extends State<FlashcardStatsScreen> {
  int _selectedPeriod = 30;

  @override
  void initState() {
    super.initState();
    print('STATS SCREEN DEBUG: initState called');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('STATS SCREEN DEBUG: PostFrameCallback called');
      try {
        final provider = Provider.of<FlashcardProvider>(context, listen: false);
        print('STATS SCREEN DEBUG: Provider obtained: $provider');
        if (provider != null) {
          print('STATS SCREEN DEBUG: Calling loadStats and loadAnalytics');
          provider.loadStats();
          provider.loadAnalytics(days: _selectedPeriod);
        } else {
          print('STATS SCREEN DEBUG: Provider is null!');
        }
      } catch (e) {
        print('STATS SCREEN DEBUG: Error getting provider: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('STATS SCREEN DEBUG: build method called');
    return Consumer<FlashcardProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPeriodSelector(context),
                        const SizedBox(height: 24),
                        _buildOverviewCards(provider),
                        const SizedBox(height: 24),
                        _buildAnalyticsSection(provider),
                        const SizedBox(height: 24),
                        if (provider.analytics?.studyModeDistribution != null)
                          _buildStudyModeDistribution(provider),
                        const SizedBox(height: 24),
                        if (provider.analytics?.timeDistribution != null)
                          _buildTimeDistribution(provider),
                        const SizedBox(height: 24),
                        _buildRecentSessions(provider),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Flashcard Analytics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Period',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [7, 30, 90].map((days) {
              final isSelected = _selectedPeriod == days;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPeriod = days;
                    });
                    Provider.of<FlashcardProvider>(context, listen: false)
                        .loadAnalytics(days: days);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${days}D',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(FlashcardProvider provider) {
    final analytics = provider.analytics;
    
    if (analytics == null) {
      return _buildLoadingState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('📊 Overview'),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildEnhancedStatCard(
              icon: Icons.quiz_outlined,
              title: 'Sessions',
              value: '${analytics.totalSessions}',
              subtitle: 'Completed',
              color: const Color(0xFF6366F1),
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            _buildEnhancedStatCard(
              icon: Icons.style_outlined,
              title: 'Cards',
              value: '${analytics.cardsStudied}',
              subtitle: 'Studied',
              color: const Color(0xFF10B981),
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            _buildEnhancedStatCard(
              icon: Icons.trending_up_outlined,
              title: 'Accuracy',
              value: '${analytics.accuracyPercentage.toStringAsFixed(1)}%',
              subtitle: 'Success Rate',
              color: const Color(0xFFF59E0B),
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            _buildEnhancedStatCard(
              icon: Icons.timer_outlined,
              title: 'Study Time',
              value: '${(analytics.studyTimeMinutes / 60).toStringAsFixed(1)}h',
              subtitle: 'Total Time',
              color: const Color(0xFF8B5CF6),
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection(FlashcardProvider provider) {
    final analytics = provider.analytics;
    
    if (analytics == null) {
      return _buildLoadingState();
    }

    // Debug logging for UI values
    print('UI DEBUG: correctAnswers = ${analytics.correctAnswers}');
    print('UI DEBUG: incorrectAnswers = ${analytics.incorrectAnswers}');
    print('UI DEBUG: averageResponseTime = ${analytics.averageResponseTime}');
    print('UI DEBUG: studyTimeMinutes = ${analytics.studyTimeMinutes}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('🎯 Performance'),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildPerformanceCard(
                      icon: Icons.check_circle_outline,
                      title: 'Correct',
                      value: '${analytics.correctAnswers ?? 0}',
                      color: const Color(0xFF10B981),
                      percentage: analytics.correctAnswers != null && analytics.incorrectAnswers != null
                          ? (analytics.correctAnswers! / (analytics.correctAnswers! + analytics.incorrectAnswers!) * 100)
                          : 0.0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPerformanceCard(
                      icon: Icons.cancel_outlined,
                      title: 'Incorrect',
                      value: '${analytics.incorrectAnswers ?? 0}',
                      color: const Color(0xFFEF4444),
                      percentage: analytics.correctAnswers != null && analytics.incorrectAnswers != null
                          ? (analytics.incorrectAnswers! / (analytics.correctAnswers! + analytics.incorrectAnswers!) * 100)
                          : 0.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildPerformanceCard(
                      icon: Icons.speed_outlined,
                      title: 'Avg Response',
                      value: '${analytics.averageResponseTime?.toStringAsFixed(1) ?? '0.0'}s',
                      color: const Color(0xFF3B82F6),
                      showPercentage: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPerformanceCard(
                      icon: _getTrendIcon(analytics.improvementTrend),
                      title: 'Trend',
                      value: analytics.improvementTrend.toUpperCase(),
                      color: _getTrendColor(analytics.improvementTrend),
                      showPercentage: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudyModeDistribution(FlashcardProvider provider) {
    final analytics = provider.analytics;
    final distribution = analytics?.studyModeDistribution;
    
    if (distribution == null || distribution.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = distribution.values.fold(0, (sum, count) => sum + count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('📚 Study Modes'),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: distribution.entries.map((entry) {
              final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
              return _buildEnhancedModeItem(entry.key, entry.value, percentage);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDistribution(FlashcardProvider provider) {
    final analytics = provider.analytics;
    final distribution = analytics?.timeDistribution;
    
    if (distribution == null || distribution.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = distribution.values.fold(0, (sum, count) => sum + count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Time Distribution'),
        const SizedBox(height: 16),
        ...distribution.entries.map((entry) {
          final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
          return _buildTimeItem(entry.key, entry.value, percentage);
        }).toList(),
      ],
    );
  }

  Widget _buildRecentSessions(FlashcardProvider provider) {
    final sessions = provider.sessions.where((s) => !s.isActive).take(5).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Recent Sessions'),
        const SizedBox(height: 16),
        if (sessions.isEmpty)
          _buildEmptyState('No completed sessions yet')
        else
          ...sessions.map((session) => _buildSessionCard(session)).toList(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }


  Widget _buildTimeItem(String timeRange, int count, double percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            color: _getTimeColor(timeRange),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTimeDisplayName(timeRange),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$count sessions (${percentage.toStringAsFixed(1)}%)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(dynamic session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.quiz,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session ${session.id}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${session.totalCards} cards • ${session.studyMode}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return Colors.green;
      case 'declining':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color _getModeColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'practice':
        return Colors.blue;
      case 'review':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  Color _getTimeColor(String timeRange) {
    switch (timeRange.toLowerCase()) {
      case 'morning':
        return Colors.orange;
      case 'afternoon':
        return Colors.blue;
      case 'evening':
        return Colors.purple;
      case 'night':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _getTimeDisplayName(String timeRange) {
    switch (timeRange.toLowerCase()) {
      case 'morning':
        return 'Morning (6AM-12PM)';
      case 'afternoon':
        return 'Afternoon (12PM-6PM)';
      case 'evening':
        return 'Evening (6PM-12AM)';
      case 'night':
        return 'Night (12AM-6AM)';
      default:
        return timeRange;
    }
  }

  Widget _buildEnhancedStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required LinearGradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    double? percentage,
    bool showPercentage = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showPercentage && percentage != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
            const SizedBox(height: 4),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedModeItem(String mode, int count, double percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getModeColor(mode).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getModeIcon(mode),
              color: _getModeColor(mode),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      mode.toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$count',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getModeColor(mode),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: _getModeColor(mode).withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(_getModeColor(mode)),
                  minHeight: 6,
                ),
                const SizedBox(height: 4),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getModeIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'practice':
        return Icons.school_outlined;
      case 'review':
        return Icons.refresh_outlined;
      case 'mixed':
        return Icons.shuffle_outlined;
      default:
        return Icons.quiz_outlined;
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return Icons.trending_up_outlined;
      case 'declining':
        return Icons.trending_down_outlined;
      default:
        return Icons.trending_flat_outlined;
    }
  }
}