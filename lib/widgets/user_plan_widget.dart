import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_plan_provider.dart';

class UserPlanWidget extends StatelessWidget {
  const UserPlanWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPlanProvider>(
      builder: (context, userPlanProvider, child) {
        if (userPlanProvider.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (userPlanProvider.error != null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load plan information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userPlanProvider.error!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => userPlanProvider.refreshUserPlan(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlanHeader(context, userPlanProvider),
                const SizedBox(height: 16),
                _buildPlanFeatures(context, userPlanProvider),
                const SizedBox(height: 16),
                _buildUsageStats(context, userPlanProvider),
                if (userPlanProvider.subscriptionExpiresAt != null) ...[
                  const SizedBox(height: 16),
                  _buildExpirationInfo(context, userPlanProvider),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanHeader(BuildContext context, UserPlanProvider provider) {
    final planName = provider.planName.toUpperCase();
    final isPremium = provider.isPremium;
    final isActive = provider.isActive;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPremium ? Colors.amber : Colors.blue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            planName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          isActive ? Icons.check_circle : Icons.cancel,
          color: isActive ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            color: isActive ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        if (isPremium)
          const Icon(Icons.star, color: Colors.amber, size: 20),
      ],
    );
  }

  Widget _buildPlanFeatures(BuildContext context, UserPlanProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Features',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildFeatureItem(
          context,
          'Voice Cloning',
          provider.canUseVoiceCloning,
          Icons.record_voice_over,
        ),
        _buildFeatureItem(
          context,
          'Unlimited TTS',
          provider.hasUnlimitedTts,
          Icons.volume_up,
        ),
        _buildFeatureItem(
          context,
          'Custom Voices',
          provider.canUseCustomVoices,
          Icons.voice_over_off,
        ),
        _buildFeatureItem(
          context,
          'High Quality Audio',
          provider.hasHighQualityAudio,
          Icons.high_quality,
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    String title,
    bool isEnabled,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isEnabled ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isEnabled ? Colors.black87 : Colors.grey,
                fontWeight: isEnabled ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          Icon(
            isEnabled ? Icons.check : Icons.close,
            size: 16,
            color: isEnabled ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStats(BuildContext context, UserPlanProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Usage Statistics',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildUsageItem(
          context,
          'Characters Used',
          '${provider.charactersUsed.toString()} / ${provider.charactersLimit.toString()}',
          provider.characterUsagePercentage,
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildUsageItem(
          context,
          'Voice Clones Used',
          '${provider.voiceClonesUsed} / ${provider.voiceClonesLimit}',
          provider.voiceCloneUsagePercentage,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildUsageItem(
    BuildContext context,
    String title,
    String usage,
    double percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              usage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 2),
        Text(
          '${percentage.toStringAsFixed(1)}% used',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildExpirationInfo(BuildContext context, UserPlanProvider provider) {
    final expiresAt = provider.subscriptionExpiresAt!;
    final now = DateTime.now();
    final daysUntilExpiry = expiresAt.difference(now).inDays;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: daysUntilExpiry <= 7 ? Colors.orange[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: daysUntilExpiry <= 7 ? Colors.orange : Colors.blue,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: daysUntilExpiry <= 7 ? Colors.orange : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscription Expires',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${expiresAt.day}/${expiresAt.month}/${expiresAt.year}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            daysUntilExpiry > 0 
                ? '$daysUntilExpiry days left'
                : 'Expired',
            style: TextStyle(
              color: daysUntilExpiry <= 7 ? Colors.orange : Colors.blue,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Compact version for smaller spaces
class UserPlanCompactWidget extends StatelessWidget {
  const UserPlanCompactWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPlanProvider>(
      builder: (context, userPlanProvider, child) {
        if (userPlanProvider.isLoading) {
          return const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (userPlanProvider.error != null) {
          return const Icon(Icons.error, color: Colors.red, size: 20);
        }

        final planName = userPlanProvider.planName.toUpperCase();
        final isPremium = userPlanProvider.isPremium;
        final isActive = userPlanProvider.isActive;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPremium ? Colors.amber : Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                planName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isActive ? Icons.check_circle : Icons.cancel,
              color: isActive ? Colors.green : Colors.red,
              size: 16,
            ),
          ],
        );
      },
    );
  }
}
