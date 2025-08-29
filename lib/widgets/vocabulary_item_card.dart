import 'package:flutter/material.dart';
import '../models/vocabulary_item.dart';

class VocabularyItemCard extends StatelessWidget {
  final VocabularyItem item;
  final VoidCallback? onTap;
  final VoidCallback? onProgressTap;

  const VocabularyItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onProgressTap,
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
              // Top row with word and progress button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.word,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Progress button (ellipsis)
                  if (onProgressTap != null)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: IconButton(
                        onPressed: onProgressTap,
                        icon: Icon(
                          Icons.more_horiz,
                          color: Colors.grey.shade700,
                          size: 28,
                        ),
                        tooltip: 'Learning Progress',
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Level and part of speech row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getLevelColor(item.level).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.level.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: _getLevelColor(item.level),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.partOfSpeech.replaceAll('_', ' '),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Definition (moved up, styled as meaning - now first)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology_outlined, size: 18, color: Colors.green.shade700),
                        const SizedBox(width: 6),
                        Text(
                          'Meaning',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.definition,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.green.shade900,
                        height: 1.5,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Example (moved down, now second)
              if (item.example.isNotEmpty) ...[
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
                          Icon(Icons.lightbulb_outline, size: 18, color: Colors.blue.shade700),
                          const SizedBox(width: 6),
                          Text(
                            'Example',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.example,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.blue.shade900,
                          height: 1.5,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (item.exampleTranslation.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.exampleTranslation,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
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