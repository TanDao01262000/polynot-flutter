import 'package:flutter/material.dart';
import '../models/vocabulary_item.dart';
import '../models/vocabulary_category.dart';
import '../widgets/vocabulary_item_card.dart';

class VocabularyInteractionCard extends StatefulWidget {
  final VocabularyItem item;
  final VoidCallback onFavorite;
  final VoidCallback onHide;
  final Function(int) onRate;
  final VoidCallback onReview;
  final Function(String) onAddNote;
  final Function(String) onAddToList;
  final List<VocabularyPersonalList> personalLists;

  const VocabularyInteractionCard({
    super.key,
    required this.item,
    required this.onFavorite,
    required this.onHide,
    required this.onRate,
    required this.onReview,
    required this.onAddNote,
    required this.onAddToList,
    required this.personalLists,
  });

  @override
  State<VocabularyInteractionCard> createState() => _VocabularyInteractionCardState();
}

class _VocabularyInteractionCardState extends State<VocabularyInteractionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: widget.item.isFavorite 
            ? BorderSide(color: Colors.orange.shade300, width: 2)
            : BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Main vocabulary card
          VocabularyItemCard(
            item: widget.item,
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
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
                // Favorite button
                IconButton(
                  onPressed: widget.onFavorite,
                  icon: Icon(
                    widget.item.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: widget.item.isFavorite ? Colors.red : null,
                    size: 20,
                  ),
                  tooltip: widget.item.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                ),
                
                // Hide button
                IconButton(
                  onPressed: widget.onHide,
                  icon: Icon(
                    widget.item.isHidden ? Icons.visibility_off : Icons.visibility,
                    color: widget.item.isHidden ? Colors.orange : null,
                    size: 20,
                  ),
                  tooltip: widget.item.isHidden ? 'Show item' : 'Hide item',
                ),
                
                // Difficulty rating
                Expanded(
                  child: Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => widget.onRate(index + 1),
                        child: Icon(
                          index < (widget.item.difficultyRating ?? 0) 
                              ? Icons.star 
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        ),
                      );
                    }),
                  ),
                ),
                
                // Review button
                IconButton(
                  onPressed: widget.onReview,
                  icon: Icon(
                    widget.item.lastReviewed != null ? Icons.check_circle : Icons.check_circle_outline,
                    color: widget.item.lastReviewed != null ? Colors.green : null,
                    size: 20,
                  ),
                  tooltip: 'Mark as reviewed',
                ),
                
                // Notes button
                IconButton(
                  onPressed: () => _showNotesDialog(context),
                  icon: Icon(
                    widget.item.personalNotes?.isNotEmpty == true 
                        ? Icons.note 
                        : Icons.note_outlined,
                    color: widget.item.personalNotes?.isNotEmpty == true ? Colors.blue : null,
                    size: 20,
                  ),
                  tooltip: 'Add notes',
                ),
                
                // Add to list button
                if (widget.personalLists.isNotEmpty)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.add, size: 20),
                    tooltip: 'Add to list',
                    onSelected: widget.onAddToList,
                    itemBuilder: (context) => widget.personalLists.map((list) {
                      return PopupMenuItem(
                        value: list.id,
                        child: Row(
                          children: [
                            const Icon(Icons.bookmark, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(list.name)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                
                // Expand button
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          
          // Expanded content
          if (_isExpanded) ...[
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Translation
                  if (widget.item.translation.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.translate, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Translation: ${widget.item.translation}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Personal notes
                  if (widget.item.personalNotes?.isNotEmpty == true) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Notes: ${widget.item.personalNotes}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Difficulty rating display
                  if (widget.item.difficultyRating != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(
                          'Difficulty: ${widget.item.difficultyRating}/5',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Review info
                  if (widget.item.reviewCount > 0 || widget.item.lastReviewed != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Reviewed ${widget.item.reviewCount} time${widget.item.reviewCount == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (widget.item.lastReviewed != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Last reviewed: ${_formatDate(widget.item.lastReviewed!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                  
                  // Metadata
                  Text(
                    'Created: ${_formatDate(widget.item.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  if (widget.item.targetLanguage != widget.item.originalLanguage)
                    Text(
                      '${widget.item.targetLanguage} → ${widget.item.originalLanguage}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showNotesDialog(BuildContext context) {
    final noteController = TextEditingController(text: widget.item.personalNotes ?? '');
    
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
              widget.onAddNote(noteController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
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
}
