import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/social_models.dart';
import '../providers/social_provider.dart';

class SocialPostCard extends StatelessWidget {
  final SocialPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const SocialPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    final socialProvider = Provider.of<SocialProvider>(context, listen: false);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2C3E50).withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, socialProvider),
            
            // Content
            _buildContent(context),
            
            // Metadata (if available)
            if (post.metadata != null && post.metadata!.isNotEmpty)
              _buildMetadata(context),
            
            // Actions
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SocialProvider socialProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE8F4FD),
            backgroundImage: post.authorAvatar != null
                ? NetworkImage(post.authorAvatar!)
                : null,
            child: post.authorAvatar == null
                ? Text(
                    post.userName.isNotEmpty ? post.userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Color(0xFF3498DB),
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          
          const SizedBox(width: 12),
          
          // User info and post type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      post.userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getPostTypeColor(post.postType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        socialProvider.getPostTypeDisplayName(post.postType),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _getPostTypeColor(post.postType),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  socialProvider.formatTimeAgo(post.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
          
          // Visibility indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getVisibilityIcon(post.visibility),
              size: 16,
              color: const Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.title.isNotEmpty) ...[
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5D6D7E),
              height: 1.4,
            ),
          ),
          if (post.pointsEarned > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.stars,
                  size: 16,
                  color: Color(0xFFF39C12),
                ),
                const SizedBox(width: 4),
                Text(
                  '+${post.pointsEarned} points',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFF39C12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: post.metadata!.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(
                    '${entry.key}: ',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5D6D7E),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          // Like button
          _buildActionButton(
            icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
            label: post.likesCount.toString(),
            color: post.isLiked ? Colors.red : const Color(0xFF7F8C8D),
            onTap: onLike,
          ),
          
          
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPostTypeColor(String postType) {
    switch (postType) {
      case PostTypes.achievement:
        return const Color(0xFFE74C3C);
      case PostTypes.levelUp:
        return const Color(0xFF27AE60);
      case PostTypes.streak:
        return const Color(0xFFF39C12);
      case PostTypes.conversation:
        return const Color(0xFF3498DB);
      case PostTypes.learningTip:
        return const Color(0xFF9B59B6);
      case PostTypes.milestone:
        return const Color(0xFF1ABC9C);
      case PostTypes.challenge:
        return const Color(0xFFE67E22);
      default:
        return const Color(0xFF7F8C8D);
    }
  }

  IconData _getVisibilityIcon(String visibility) {
    switch (visibility) {
      case PostVisibility.public:
        return Icons.public;
      case PostVisibility.friends:
        return Icons.people;
      case PostVisibility.private:
        return Icons.lock;
      case PostVisibility.levelRestricted:
        return Icons.school;
      case PostVisibility.studyGroup:
        return Icons.group;
      default:
        return Icons.visibility;
    }
  }
}
