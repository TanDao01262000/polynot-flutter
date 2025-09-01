import 'package:flutter/material.dart';
import '../models/vocabulary_item.dart';
import '../models/vocabulary_category.dart';
import '../widgets/vocabulary_item_card.dart';

class VocabularyInteractionCard extends StatelessWidget {
  final VocabularyItem item;
  final VoidCallback onFavorite;
  final VoidCallback onHide;
  final VoidCallback onReview;
  final Function(String) onAddNote;
  final Function(int)? onRate;
  final Function(String) onAddToList;
  final List<VocabularyPersonalList> personalLists;

  const VocabularyInteractionCard({
    super.key,
    required this.item,
    required this.onFavorite,
    required this.onHide,
    required this.onReview,
    required this.onAddNote,
    this.onRate,
    required this.onAddToList,
    required this.personalLists,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: item.isFavorite 
            ? BorderSide(color: Colors.orange.shade300, width: 3)
            : BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Main vocabulary card
          VocabularyItemCard(
            item: item,
            onTap: () {
              // Handle expansion in parent widget if needed
            },
            onProgressTap: () => _showProgressDialog(context),
          ),
          
          // Interaction buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Primary actions (most important)
                Row(
                  children: [
                    // Favorite button
                    IconButton(
                      onPressed: onFavorite,
                      icon: Icon(
                        item.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: item.isFavorite ? Colors.red : Colors.grey.shade600,
                        size: 24,
                      ),
                      tooltip: item.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                    ),
                    
                    // Review button
                    IconButton(
                      onPressed: onReview,
                      icon: Icon(
                        item.lastReviewed != null ? Icons.check_circle : Icons.check_circle_outline,
                        color: item.lastReviewed != null ? Colors.green : Colors.grey.shade600,
                        size: 24,
                      ),
                      tooltip: item.lastReviewed != null ? 'Unmark as reviewed' : 'Mark as reviewed',
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Secondary actions (less important)
                Row(
                  children: [
                    // Hide button
                    IconButton(
                      onPressed: onHide,
                      icon: Icon(
                        item.isHidden ? Icons.visibility_off : Icons.visibility,
                        color: item.isHidden ? Colors.orange : Colors.grey.shade600,
                        size: 20,
                      ),
                      tooltip: item.isHidden ? 'Show item' : 'Hide item',
                    ),
                    
                    // Notes button
                    IconButton(
                      onPressed: () => _showNotesDialog(context),
                      icon: Icon(
                        item.personalNotes?.isNotEmpty == true 
                            ? Icons.note 
                            : Icons.note_outlined,
                        color: item.personalNotes?.isNotEmpty == true ? Colors.blue : Colors.grey.shade600,
                        size: 20,
                      ),
                      tooltip: 'Add notes',
                    ),
                    
                    // Rate difficulty button
                    if (onRate != null)
                      PopupMenuButton<int>(
                        icon: Icon(
                          item.difficultyRating != null ? Icons.star : Icons.star_outline,
                          size: 20,
                          color: item.difficultyRating != null ? Colors.amber : Colors.grey.shade600,
                        ),
                        tooltip: 'Rate difficulty',
                        onSelected: onRate,
                        itemBuilder: (context) => List.generate(5, (index) {
                          final rating = index + 1;
                          final isSelected = item.difficultyRating == rating;
                          return PopupMenuItem(
                            value: rating,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: isSelected ? Colors.amber : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text('$rating - ${_getDifficultyText(rating)}'),
                              ],
                            ),
                          );
                        }),
                      ),
                    
                    // Add to list button (commented out for now)
                    // if (personalLists.isNotEmpty)
                    //   PopupMenuButton<String>(
                    //     icon: Icon(Icons.bookmark_add, size: 20, color: Colors.grey.shade600),
                    //         tooltip: 'Add to list',
                    //         onSelected: onAddToList,
                    //         itemBuilder: (context) => personalLists.map((list) {
                    //           return PopupMenuItem(
                    //             value: list.id,
                    //             child: Row(
                    //               children: [
                    //                 const Icon(Icons.bookmark, size: 16),
                    //                 const SizedBox(width: 8),
                    //                 Expanded(child: Text(list.name)),
                    //               ],
                    //             ),
                    //           );
                    //         }).toList(),
                    //       ),
                  ],
                ),
              ],
            ),
          ),
          
          // Expanded content (simplified)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal notes
                if (item.personalNotes?.isNotEmpty == true) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.note, size: 18, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Your Notes',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.personalNotes!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.blue.shade900,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Learning stats (hidden behind ellipsis)
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotesDialog(BuildContext context) {
    final noteController = TextEditingController(text: item.personalNotes ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personal Notes'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Add your personal notes about this vocabulary...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          maxLength: 500,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onAddNote(noteController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.trending_up, color: Colors.green.shade700),
            const SizedBox(width: 8),
            const Text('Learning Progress'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vocabulary: ${item.word}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  item.reviewCount == 0 ? Icons.play_circle_outline : Icons.check_circle,
                  color: item.reviewCount == 0 ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  item.reviewCount == 0 
                      ? '🎯 Ready to start learning!' 
                      : '🔥 Reviewed ${item.reviewCount} time${item.reviewCount == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (item.lastReviewed != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Last reviewed: ${_formatDate(item.lastReviewed!)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
            if (item.difficultyRating != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Difficulty: ${_getDifficultyText(item.difficultyRating!)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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

  String _getDifficultyText(int rating) {
    switch (rating) {
      case 1:
        return 'Very Easy';
      case 2:
        return 'Easy';
      case 3:
        return 'Medium';
      case 4:
        return 'Hard';
      case 5:
        return 'Very Hard';
      default:
        return 'Unknown';
    }
  }

  void _showFunReaction(BuildContext context) {
    final reactions = ['🎉', '🔥', '💪', '🎯', '🚀', '⭐', '💡', '🎨', '🌈', '✨'];
    final randomReaction = reactions[DateTime.now().millisecond % reactions.length];
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$randomReaction Awesome! You\'re learning "${item.word}"! $randomReaction'),
        backgroundColor: Colors.purple,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showLearningStreak(BuildContext context) {
    final streak = item.reviewCount;
    String message;
    Color backgroundColor;
    
    if (streak == 0) {
      message = '🚀 Start your learning journey with "${item.word}"!';
      backgroundColor = Colors.blue;
    } else if (streak < 3) {
      message = '🔥 Great start! You\'ve reviewed "${item.word}" $streak times!';
      backgroundColor = Colors.orange;
    } else if (streak < 10) {
      message = '💪 Amazing! You\'re mastering "${item.word}"! ($streak reviews)';
      backgroundColor = Colors.green;
    } else {
      message = '🏆 Legend! You\'ve reviewed "${item.word}" $streak times!';
      backgroundColor = Colors.purple;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
