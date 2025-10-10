import 'package:flutter/material.dart';
import '../models/study_together_models.dart';

class VocabularyDiscoverySimpleCard extends StatelessWidget {
  final VocabularyDiscovery discovery;
  final VoidCallback onTap;
  final VoidCallback? onSave;
  final bool isSaving;
  final bool isSaved;
  final bool isAlreadyInList;

  const VocabularyDiscoverySimpleCard({
    super.key,
    required this.discovery,
    required this.onTap,
    this.onSave,
    this.isSaving = false,
    this.isSaved = false,
    this.isAlreadyInList = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Word and author info with save button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      discovery.word,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  // Save button or status indicator
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: isAlreadyInList
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: Colors.orange.shade600, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'In List',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : onSave != null
                            ? IconButton(
                                onPressed: isSaving ? null : onSave,
                                icon: isSaved 
                                    ? Icon(Icons.check_circle, color: Colors.green.shade600, size: 20)
                                    : isSaving
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : Icon(Icons.bookmark_add_outlined, color: Colors.blue.shade600, size: 20),
                                tooltip: isSaved ? 'Saved to your vocabulary' : 'Save to your vocabulary',
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              )
                            : const SizedBox.shrink(),
                  ),
                  // Author info
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      discovery.authorName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Language and level
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getLevelColor(discovery.level).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      discovery.level.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getLevelColor(discovery.level),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      discovery.language,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Translation/Context
              if (discovery.context.isNotEmpty) ...[
                Text(
                  discovery.context,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.purple.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              // Click hint
              Row(
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to see full details',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
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
