import 'package:flutter/material.dart';
import '../models/social_models.dart';

class SocialTrendingCard extends StatelessWidget {
  final List<TrendingWord> trendingContent;

  const SocialTrendingCard({
    super.key,
    required this.trendingContent,
  });

  @override
  Widget build(BuildContext context) {
    if (trendingContent.isEmpty) {
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
                    Icons.trending_up,
                    size: 20,
                    color: Color(0xFF3498DB),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Trending Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
          
          // Trending items
          Container(
            height: 120,
            padding: const EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: trendingContent.length,
              itemBuilder: (context, index) {
                final trending = trendingContent[index];
                return _buildTrendingItem(context, trending);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingItem(BuildContext context, TrendingWord trending) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Content type and popularity
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: _getContentTypeColor(trending.contentType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  _getContentTypeIcon(trending.contentType),
                  size: 10,
                  color: _getContentTypeColor(trending.contentType),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up,
                      size: 8,
                      color: Color(0xFFE74C3C),
                    ),
                    const SizedBox(width: 1),
                    Text(
                      '${(trending.popularityScore * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE74C3C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 6),
          
          // Word/content
          Text(
            trending.content,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 3),
          
          // Language and level
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trending.language,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3498DB),
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trending.level,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF27AE60),
                  ),
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Usage count
          Row(
            children: [
              Icon(
                Icons.people,
                size: 10,
                color: const Color(0xFF7F8C8D),
              ),
              const SizedBox(width: 4),
              Text(
                '${trending.usageCount} studying',
                style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xFF7F8C8D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getContentTypeColor(String contentType) {
    switch (contentType) {
      case 'word':
        return const Color(0xFF3498DB);
      case 'phrase':
        return const Color(0xFF27AE60);
      case 'grammar':
        return const Color(0xFF9B59B6);
      case 'conversation':
        return const Color(0xFFF39C12);
      default:
        return const Color(0xFF7F8C8D);
    }
  }

  IconData _getContentTypeIcon(String contentType) {
    switch (contentType) {
      case 'word':
        return Icons.text_fields;
      case 'phrase':
        return Icons.format_quote;
      case 'grammar':
        return Icons.article;
      case 'conversation':
        return Icons.chat;
      default:
        return Icons.info;
    }
  }
}


