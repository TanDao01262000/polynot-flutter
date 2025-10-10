import 'package:flutter/material.dart';
import '../models/social_models.dart';

class SocialRecommendationCard extends StatelessWidget {
  final List<SmartFeedRecommendation> recommendations;

  const SocialRecommendationCard({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: Color(0xFF3498DB),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Recommended for You',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
          
          // Recommendations list
          ...recommendations.map((recommendation) => 
            _buildRecommendationItem(context, recommendation)),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(
    BuildContext context,
    SmartFeedRecommendation recommendation,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE9ECEF),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Content type icon
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _getContentTypeColor(recommendation.contentType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  _getContentTypeIcon(recommendation.contentType),
                  size: 14,
                  color: _getContentTypeColor(recommendation.contentType),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  recommendation.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${(recommendation.relevanceScore * 100).toInt()}% match',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3498DB),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            recommendation.content,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF5D6D7E),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 12,
                color: const Color(0xFF7F8C8D),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  recommendation.reason,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7F8C8D),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              if (recommendation.authorLevel.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    recommendation.authorLevel,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF27AE60),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getContentTypeColor(String contentType) {
    switch (contentType) {
      case 'learning_tip':
        return const Color(0xFF9B59B6);
      case 'grammar':
        return const Color(0xFF3498DB);
      case 'vocabulary':
        return const Color(0xFF27AE60);
      case 'pronunciation':
        return const Color(0xFFE74C3C);
      case 'conversation':
        return const Color(0xFFF39C12);
      default:
        return const Color(0xFF7F8C8D);
    }
  }

  IconData _getContentTypeIcon(String contentType) {
    switch (contentType) {
      case 'learning_tip':
        return Icons.lightbulb;
      case 'grammar':
        return Icons.article;
      case 'vocabulary':
        return Icons.book;
      case 'pronunciation':
        return Icons.record_voice_over;
      case 'conversation':
        return Icons.chat;
      default:
        return Icons.info;
    }
  }
}



