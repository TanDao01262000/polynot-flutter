import 'package:flutter/material.dart';
import '../models/flashcard_models.dart';

// Progress indicator for flashcard sessions
class FlashcardProgressIndicator extends StatelessWidget {
  final int currentCard;
  final int totalCards;
  final double? accuracy;
  final Color? progressColor;
  final Color? backgroundColor;

  const FlashcardProgressIndicator({
    super.key,
    required this.currentCard,
    required this.totalCards,
    this.accuracy,
    this.progressColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCards > 0 ? currentCard / totalCards : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667eea).withOpacity(0.1),
            const Color(0xFF764ba2).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFF667eea).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Single row with all info
          Row(
            children: [
              Expanded(
                child: Text(
                  'Card $currentCard/$totalCards',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (accuracy != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getAccuracyColor(accuracy!),
                        _getAccuracyColor(accuracy!).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _getAccuracyColor(accuracy!).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${accuracy!.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey.withOpacity(0.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressColor ?? const Color(0xFF667eea),
                ),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${((currentCard / totalCards) * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${totalCards - currentCard} left',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return Colors.green;
    if (accuracy >= 60) return Colors.orange;
    return Colors.red;
  }
}

// Main flashcard widget
class FlashcardWidget extends StatefulWidget {
  final FlashcardCard card;
  final String studyMode;
  final VoidCallback? onFlip;
  final bool showAnswer;
  final bool isFlipped;

  const FlashcardWidget({
    super.key,
    required this.card,
    required this.studyMode,
    this.onFlip,
    this.showAnswer = false,
    this.isFlipped = false,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _isFlipped = widget.isFlipped;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_animationController.isAnimating) return;
    
    setState(() {
      _isFlipped = !_isFlipped;
    });
    
    if (_isFlipped) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    
    widget.onFlip?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isShowingFront = _flipAnimation.value < 0.5;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * 3.14159),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..scale(isShowingFront ? 1.0 : -1.0, 1.0, 1.0),
              child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 200,
                maxHeight: 250,
              ),
              decoration: BoxDecoration(
                gradient: isShowingFront 
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF667eea),
                          const Color(0xFF764ba2),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFf093fb),
                          const Color(0xFFf5576c),
                        ],
                      ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isShowingFront 
                        ? const Color(0xFF667eea).withOpacity(0.3)
                        : const Color(0xFFf093fb).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isShowingFront ? _buildFront() : _buildBack(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main content with better typography
          Flexible(
            child: Text(
              _getFrontContent(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.0,
                letterSpacing: 0.0,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Part of speech removed to save space
          // const SizedBox(height: 6),
          // 
          // // Part of speech with modern styling
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          //   decoration: BoxDecoration(
          //     color: Colors.white.withOpacity(0.25),
          //     borderRadius: BorderRadius.circular(15),
          //     border: Border.all(
          //       color: Colors.white.withOpacity(0.4),
          //       width: 1,
          //     ),
          //   ),
          //   child: Text(
          //     widget.card.partOfSpeech.toUpperCase(),
          //     style: const TextStyle(
          //       color: Colors.white,
          //       fontWeight: FontWeight.w500,
          //       fontSize: 9,
          //       letterSpacing: 0.5,
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 8),
          
          // Instruction text with better styling - removed to save space
          // Text(
          //   '👆 Tap to reveal answer',
          //   style: TextStyle(
          //     color: Colors.white.withOpacity(0.8),
          //     fontSize: 10,
          //     fontWeight: FontWeight.w500,
          //     fontStyle: FontStyle.italic,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Main answer content - flexible space
          Expanded(
            flex: 4,
            child: Center(
              child: Text(
                _getBackContent(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          
          // Example section - fixed height to prevent overflow
          if (widget.card.example.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 60,
                maxHeight: 80,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Example',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.card.example,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.card.exampleTranslation.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.card.exampleTranslation,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.ltr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          
          // Spacer to push instruction to bottom
          const Spacer(),
          
          // Instruction text - fixed at bottom
          Text(
            '👆 Tap to flip back',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _getFrontContent() {
    // Front side always shows the question
    switch (widget.studyMode) {
      case 'review':
        return widget.card.definition;
      case 'practice':
      default:
        return widget.card.word;
    }
  }

  String _getBackContent() {
    // Back side always shows the answer
    switch (widget.studyMode) {
      case 'review':
        return widget.card.word;
      case 'practice':
      default:
        return widget.card.definition;
    }
  }
}

// Answer input widget
class FlashcardAnswerInput extends StatefulWidget {
  final String studyMode;
  final VoidCallback? onSubmit;
  final Function(String)? onAnswerChanged;
  final bool isLoading;
  final String? hint;

  const FlashcardAnswerInput({
    super.key,
    required this.studyMode,
    this.onSubmit,
    this.onAnswerChanged,
    this.isLoading = false,
    this.hint,
  });

  @override
  State<FlashcardAnswerInput> createState() => _FlashcardAnswerInputState();
}

class _FlashcardAnswerInputState extends State<FlashcardAnswerInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getInputLabel(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              hintText: widget.hint ?? _getHintText(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _hasText && !widget.isLoading
                    ? () {
                        final answer = _controller.text.trim();
                        widget.onAnswerChanged?.call(answer);
                        widget.onSubmit?.call();
                      }
                    : null,
              ),
            ),
            onChanged: (value) {
              widget.onAnswerChanged?.call(value.trim());
            },
            onSubmitted: (value) {
              if (value.trim().isNotEmpty && !widget.isLoading) {
                final answer = value.trim();
                widget.onAnswerChanged?.call(answer);
                widget.onSubmit?.call();
              }
            },
          ),
        ],
      ),
    );
  }

  String _getInputLabel() {
    switch (widget.studyMode) {
      case 'review':
        return 'What is the word?';
      case 'practice':
        return 'What does this word mean?';
      default:
        return 'Your answer:';
    }
  }

  String _getHintText() {
    switch (widget.studyMode) {
      case 'review':
        return 'Enter the word...';
      case 'practice':
        return 'Enter the definition...';
      default:
        return 'Enter your answer...';
    }
  }
}

// Difficulty rating selector
class DifficultyRatingSelector extends StatelessWidget {
  final List<DifficultyRating> ratings;
  final String? selectedRating;
  final Function(String) onRatingSelected;
  final bool isLoading;

  const DifficultyRatingSelector({
    super.key,
    required this.ratings,
    this.selectedRating,
    required this.onRatingSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFf093fb).withOpacity(0.1),
            const Color(0xFFf5576c).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFf093fb).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFf093fb).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: const Color(0xFFf093fb),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'How difficult was this?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ratings.map((rating) {
              final isSelected = selectedRating == rating.value;
              final color = _getRatingColor(rating.value, theme);
              
              return GestureDetector(
                onTap: isLoading ? null : () => onRatingSelected(rating.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected 
                        ? LinearGradient(
                            colors: [color, color.withOpacity(0.8)],
                          )
                        : null,
                    color: isSelected ? null : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: color,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ] : null,
                  ),
                  child: Text(
                    rating.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : color,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(String rating, ThemeData theme) {
    switch (rating) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      case 'again':
        return Colors.purple;
      default:
        return theme.primaryColor;
    }
  }
}

// Session stats display
class SessionStatsDisplay extends StatelessWidget {
  final SessionStats stats;
  final Color? accentColor;

  const SessionStatsDisplay({
    super.key,
    required this.stats,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.primaryColor;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Correct',
                stats.correctAnswers.toString(),
                Colors.green,
                theme,
              ),
              _buildStatItem(
                'Incorrect',
                stats.incorrectAnswers.toString(),
                Colors.red,
                theme,
              ),
              _buildStatItem(
                'Remaining',
                stats.cardsRemaining.toString(),
                Colors.orange,
                theme,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Accuracy: ${stats.accuracyPercentage.toStringAsFixed(1)}%',
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.hintColor,
          ),
        ),
      ],
    );
  }
}

// Study mode selector
class StudyModeSelector extends StatelessWidget {
  final List<StudyMode> modes;
  final String? selectedMode;
  final Function(String) onModeSelected;

  const StudyModeSelector({
    super.key,
    required this.modes,
    this.selectedMode,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Study Mode',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...modes.map((mode) {
          final isSelected = selectedMode == mode.value;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(mode.name),
              subtitle: Text(mode.description),
              leading: Radio<String>(
                value: mode.value,
                groupValue: selectedMode,
                onChanged: (value) {
                  if (value != null) onModeSelected(value);
                },
              ),
              selected: isSelected,
              selectedTileColor: theme.primaryColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onTap: () => onModeSelected(mode.value),
            ),
          );
        }).toList(),
      ],
    );
  }
}

