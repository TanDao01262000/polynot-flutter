import 'package:flutter/material.dart';
import '../models/vocabulary_item.dart';
import '../utils/string_extensions.dart';

class VocabularyGenerationCard extends StatefulWidget {
  final VocabularyItem item;
  final Future<bool> Function(String) onSave;
  final VoidCallback? onTap;
  final bool isSaving;

  const VocabularyGenerationCard({
    super.key,
    required this.item,
    required this.onSave,
    this.onTap,
    this.isSaving = false,
  });

  @override
  State<VocabularyGenerationCard> createState() => _VocabularyGenerationCardState();
}

class _VocabularyGenerationCardState extends State<VocabularyGenerationCard> {
  bool _isSaving = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.item.isSaved;
  }

  @override
  void didUpdateWidget(VocabularyGenerationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.isSaved != widget.item.isSaved) {
      setState(() {
        _isSaved = widget.item.isSaved;
      });
    }
  }

  Future<void> _handleSave() async {
    if (_isSaving || _isSaved) return;

    setState(() {
      _isSaving = true;
    });

    try {
      print('Card: Starting save for item: ${widget.item.word} (ID: ${widget.item.id})');
      print('Card: Item details - Word: ${widget.item.word}, Definition: ${widget.item.definition}');
      
      if (widget.item.id.isEmpty) {
        print('Card: WARNING - Item ID is empty!');
      }
      
      final success = await widget.onSave(widget.item.id);
      print('Card: Save result for ${widget.item.word}: $success');
      
      if (success) {
        setState(() {
          _isSaved = true;
        });
      }
    } catch (e) {
      print('Card: Error saving ${widget.item.word}: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with word and part of speech
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.word,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 28,
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            widget.item.partOfSpeech.replaceAll('_', ' '),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Definition (Meaning) section
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
                      widget.item.definition,
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

              // Example section
              if (widget.item.example.isNotEmpty) ...[
                const SizedBox(height: 12),
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
                        widget.item.example,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.blue.shade900,
                          height: 1.5,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.item.exampleTranslation.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.item.exampleTranslation,
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

              // Translation section
              if (widget.item.translation.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.translate, size: 18, color: Colors.purple.shade700),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.item.targetLanguage.capitalize()} Translation',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.purple.shade700,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.item.translation,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.purple.shade900,
                          height: 1.5,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Save button
              SizedBox(
                width: double.infinity,
                child: _isSaved
                  ? ElevatedButton.icon(
                      onPressed: null, // Disabled when saved
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Saved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: (_isSaving || widget.isSaving) ? null : _handleSave,
                      icon: (_isSaving || widget.isSaving)
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                      label: Text(
                        (_isSaving || widget.isSaving) ? 'Saving...' : 'Save',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
