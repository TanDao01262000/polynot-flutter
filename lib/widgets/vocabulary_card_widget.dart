import 'package:flutter/material.dart';
import '../models/vocabulary_item.dart';
import 'tts_widgets.dart';

class VocabularyCardWidget extends StatelessWidget {
  final VocabularyItem vocabularyItem;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onSave;
  final bool showTTS;
  final bool showActions;
  final EdgeInsets? padding;

  const VocabularyCardWidget({
    super.key,
    required this.vocabularyItem,
    this.onTap,
    this.onFavorite,
    this.onSave,
    this.showTTS = true,
    this.showActions = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      margin: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with word and actions
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vocabularyItem.word,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(vocabularyItem.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getCategoryColor(vocabularyItem.category).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            vocabularyItem.partOfSpeech.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getCategoryColor(vocabularyItem.category),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // TTS Status Indicator
                  if (showTTS)
                    TTSStatusIndicator(
                      vocabEntryId: vocabularyItem.id,
                      size: 20,
                    ),
                  
                  // Action buttons
                  if (showActions) ...[
                    const SizedBox(width: 8),
                    _buildActionButton(
                      context,
                      Icons.favorite,
                      vocabularyItem.isFavorite,
                      onFavorite,
                      Colors.red,
                    ),
                    const SizedBox(width: 4),
                    _buildActionButton(
                      context,
                      Icons.bookmark,
                      vocabularyItem.isSaved,
                      onSave,
                      Colors.blue,
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Definition
              Text(
                vocabularyItem.definition,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Translation
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Text(
                  vocabularyItem.translation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              // Example section
              if (vocabularyItem.example.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Example:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vocabularyItem.example,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (vocabularyItem.exampleTranslation.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          vocabularyItem.exampleTranslation,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              
              // TTS Control Panel
              if (showTTS) ...[
                const SizedBox(height: 12),
                TTSControlPanel(
                  vocabularyItem: vocabularyItem,
                  versions: const ['normal', 'slow'],
                  showLabels: true,
                ),
              ],
              
              // Footer with metadata
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getLevelColor(vocabularyItem.level).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      vocabularyItem.level.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getLevelColor(vocabularyItem.level),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(vocabularyItem.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    bool isActive,
    VoidCallback? onPressed,
    Color color,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? color : Colors.grey,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'vocabulary':
        return Colors.blue;
      case 'phrasal_verb':
        return Colors.green;
      case 'idiom':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'a1':
        return Colors.green;
      case 'a2':
        return Colors.lightGreen;
      case 'b1':
        return Colors.orange;
      case 'b2':
        return Colors.deepOrange;
      case 'c1':
        return Colors.red;
      case 'c2':
        return Colors.red.shade800;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Compact vocabulary card for lists
class CompactVocabularyCard extends StatelessWidget {
  final VocabularyItem vocabularyItem;
  final VoidCallback? onTap;
  final bool showTTS;

  const CompactVocabularyCard({
    super.key,
    required this.vocabularyItem,
    this.onTap,
    this.showTTS = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vocabularyItem.word,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vocabularyItem.definition,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // TTS button
              if (showTTS)
                TTSButton(
                  vocabularyItem: vocabularyItem,
                  version: 'normal',
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
