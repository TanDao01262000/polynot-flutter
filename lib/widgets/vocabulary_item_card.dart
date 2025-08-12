import 'package:flutter/material.dart';
import '../models/vocabulary_item.dart';

class VocabularyItemCard extends StatelessWidget {
  final VocabularyItem item;
  final VoidCallback? onTap;

  const VocabularyItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurfaceSubtle = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.6)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Word + level chip (small)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      item.word,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getLevelColor(item.level).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.level.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: _getLevelColor(item.level),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),

              // Part of speech (subtle)
              const SizedBox(height: 2),
              Text(
                item.partOfSpeech,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: onSurfaceSubtle),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Definition
              const SizedBox(height: 6),
              Text(
                item.definition,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              // Example (collapsed style)
              if (item.example.isNotEmpty) ...[
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${item.example}"',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: onSurfaceSubtle,
                          ),
                    ),
                    if (item.exampleTranslation.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.exampleTranslation,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: onSurfaceSubtle),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
        return Colors.green;
      case 'A2':
        return Colors.lightGreen;
      case 'B1':
        return Colors.orange;
      case 'B2':
        return Colors.deepOrange;
      case 'C1':
        return Colors.red;
      case 'C2':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
} 