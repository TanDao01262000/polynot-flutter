import 'package:flutter/material.dart';
import '../models/social_models.dart';

class AchievementGallery extends StatelessWidget {
  final List<AvailableAchievement> availableAchievements;
  final List<SocialAchievement> userAchievements;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const AchievementGallery({
    super.key,
    required this.availableAchievements,
    required this.userAchievements,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3498DB),
        ),
      );
    }

    if (availableAchievements.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: onRefresh != null ? () async => onRefresh!() : () async {},
      color: const Color(0xFF3498DB),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            
            const SizedBox(height: 24),
            
            // Achievements grid
            _buildAchievementsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final unlockedCount = _getUnlockedAchievementsCount();
    final totalCount = availableAchievements.length;
    final progressPercentage = totalCount > 0 ? (unlockedCount / totalCount) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3498DB).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            '$unlockedCount of $totalCount',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'Achievements Unlocked',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressPercentage,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progressPercentage * 100).toInt()}% Complete',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: availableAchievements.length,
      itemBuilder: (context, index) {
        final availableAchievement = availableAchievements[index];
        final isUnlocked = _isAchievementUnlocked(availableAchievement.id);
        
        return _buildAchievementCard(availableAchievement, isUnlocked);
      },
    );
  }

  Widget _buildAchievementCard(AvailableAchievement achievement, bool isUnlocked) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? const Color(0xFF3498DB) : const Color(0xFFE9ECEF),
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnlocked 
                ? const Color(0xFF3498DB).withOpacity(0.1)
                : const Color(0xFF2C3E50).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Achievement icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: isUnlocked
                  ? const LinearGradient(
                      colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isUnlocked ? null : const Color(0xFFBDC3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                achievement.icon,
                style: TextStyle(
                  fontSize: 28,
                  color: isUnlocked ? Colors.white : const Color(0xFF7F8C8D),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Achievement name
          Text(
            achievement.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isUnlocked ? const Color(0xFF2C3E50) : const Color(0xFF7F8C8D),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          // Points
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.stars,
                size: 16,
                color: isUnlocked ? const Color(0xFFF39C12) : const Color(0xFFBDC3C7),
              ),
              const SizedBox(width: 4),
              Text(
                '${achievement.points} pts',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked ? const Color(0xFFF39C12) : const Color(0xFFBDC3C7),
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isUnlocked ? const Color(0xFF27AE60) : const Color(0xFFBDC3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUnlocked ? Icons.check_circle : Icons.lock,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  isUnlocked ? 'Unlocked' : 'Locked',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
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
              Icons.emoji_events_outlined,
              size: 80,
              color: const Color(0xFFBDC3C7),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Achievements Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7F8C8D),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later for new achievements!',
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

  int _getUnlockedAchievementsCount() {
    return availableAchievements.where((available) {
      return _isAchievementUnlocked(available.id);
    }).length;
  }

  bool _isAchievementUnlocked(String achievementId) {
    return userAchievements.any((userAchievement) {
      return userAchievement.achievementId == achievementId;
    });
  }
}

/// Compact achievement progress indicator
class AchievementProgressIndicator extends StatelessWidget {
  final List<AvailableAchievement> availableAchievements;
  final List<SocialAchievement> userAchievements;
  final VoidCallback? onTap;

  const AchievementProgressIndicator({
    super.key,
    required this.availableAchievements,
    required this.userAchievements,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _getUnlockedAchievementsCount();
    final totalCount = availableAchievements.length;
    final progressPercentage = totalCount > 0 ? (unlockedCount / totalCount) : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE9ECEF)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2C3E50).withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Progress info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Achievements',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$unlockedCount of $totalCount unlocked',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9ECEF),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progressPercentage,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFBDC3C7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  int _getUnlockedAchievementsCount() {
    return availableAchievements.where((available) {
      return userAchievements.any((userAchievement) {
        return userAchievement.achievementId == available.id;
      });
    }).length;
  }
}
