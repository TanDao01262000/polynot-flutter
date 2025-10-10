import 'package:flutter/material.dart';
import '../models/social_models.dart';

class AchievementNotification extends StatefulWidget {
  final SocialAchievement achievement;
  final VoidCallback? onClose;
  final Duration displayDuration;

  const AchievementNotification({
    super.key,
    required this.achievement,
    this.onClose,
    this.displayDuration = const Duration(seconds: 4),
  });

  @override
  State<AchievementNotification> createState() => _AchievementNotificationState();
}

class _AchievementNotificationState extends State<AchievementNotification>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _slideController.forward();
    _scaleController.forward();

    // Auto-hide after duration
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _hideNotification();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _hideNotification() async {
    await _slideController.reverse();
    if (mounted) {
      widget.onClose?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
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
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration header
              Row(
                children: [
                  const Icon(
                    Icons.celebration,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '🎉 Achievement Unlocked! 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 20,
                    ),
                    onPressed: _hideNotification,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Achievement details
              Row(
                children: [
                  // Achievement icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        widget.achievement.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Achievement info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.achievement.achievementName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.achievement.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.stars,
                              color: Color(0xFFFFD700),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${widget.achievement.pointsEarned} points',
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress bar (optional - could show progress towards next achievement)
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1.0, // Full progress for unlocked achievement
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Overlay widget to show achievement notifications
class AchievementNotificationOverlay extends StatefulWidget {
  final Widget child;
  final List<SocialAchievement> newAchievements;
  final VoidCallback? onAchievementDismissed;

  const AchievementNotificationOverlay({
    super.key,
    required this.child,
    required this.newAchievements,
    this.onAchievementDismissed,
  });

  @override
  State<AchievementNotificationOverlay> createState() => _AchievementNotificationOverlayState();
}

class _AchievementNotificationOverlayState extends State<AchievementNotificationOverlay> {
  List<SocialAchievement> _pendingAchievements = [];

  @override
  void initState() {
    super.initState();
    _pendingAchievements = List.from(widget.newAchievements);
  }

  @override
  void didUpdateWidget(AchievementNotificationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check for new achievements
    if (widget.newAchievements.length > oldWidget.newAchievements.length) {
      final newAchievements = widget.newAchievements
          .where((achievement) => !oldWidget.newAchievements.contains(achievement))
          .toList();
      
      setState(() {
        _pendingAchievements.addAll(newAchievements);
      });
    }
  }

  void _removeAchievement(SocialAchievement achievement) {
    setState(() {
      _pendingAchievements.remove(achievement);
    });
    widget.onAchievementDismissed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_pendingAchievements.isNotEmpty)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: _pendingAchievements.map((achievement) {
                  return AchievementNotification(
                    achievement: achievement,
                    onClose: () => _removeAchievement(achievement),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}
