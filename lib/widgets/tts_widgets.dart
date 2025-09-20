import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tts_provider.dart';
import '../models/vocabulary_item.dart';

// TTS Button Widget for vocabulary items
class TTSButton extends StatefulWidget {
  final VocabularyItem vocabularyItem;
  final String version;
  final double? size;
  final Color? color;
  final bool showLabel;
  final VoidCallback? onPressed;
  final VoidCallback? onError;

  const TTSButton({
    super.key,
    required this.vocabularyItem,
    this.version = 'normal',
    this.size,
    this.color,
    this.showLabel = false,
    this.onPressed,
    this.onError,
  });

  @override
  State<TTSButton> createState() => _TTSButtonState();
}

class _TTSButtonState extends State<TTSButton> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TTSProvider>(
      builder: (context, ttsProvider, child) {
        final isGenerating = ttsProvider.isGeneratingFor(widget.vocabularyItem.id);
        final isPlaying = ttsProvider.isPlayingFor(widget.vocabularyItem.id);
        final pronunciations = ttsProvider.getPronunciations(widget.vocabularyItem.id);
        final hasAudio = pronunciations?.versions.containsKey(widget.version) ?? false;

        return GestureDetector(
          onTap: isGenerating || isPlaying ? null : () => _handleTTSAction(ttsProvider),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getButtonColor(ttsProvider, hasAudio, isPlaying, isGenerating),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIcon(ttsProvider, hasAudio, isPlaying, isGenerating),
                if (widget.showLabel) ...[
                  const SizedBox(width: 4),
                  Text(
                    _getButtonLabel(ttsProvider, hasAudio, isPlaying, isGenerating),
                    style: TextStyle(
                      color: _getTextColor(ttsProvider, hasAudio, isPlaying, isGenerating),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getButtonColor(TTSProvider ttsProvider, bool hasAudio, bool isPlaying, bool isGenerating) {
    if (isGenerating) return Colors.orange.withOpacity(0.2);
    if (isPlaying) return Colors.green.withOpacity(0.2);
    if (hasAudio) return (widget.color ?? Colors.blue).withOpacity(0.2);
    return Colors.grey.withOpacity(0.2);
  }

  Color _getTextColor(TTSProvider ttsProvider, bool hasAudio, bool isPlaying, bool isGenerating) {
    if (isGenerating) return Colors.orange;
    if (isPlaying) return Colors.green;
    if (hasAudio) return widget.color ?? Colors.blue;
    return Colors.grey;
  }

  Widget _buildIcon(TTSProvider ttsProvider, bool hasAudio, bool isPlaying, bool isGenerating) {
    if (isGenerating) {
      return SizedBox(
        width: widget.size ?? 20,
        height: widget.size ?? 20,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      );
    }

    if (isPlaying) {
      return Icon(
        Icons.stop,
        size: widget.size ?? 20,
        color: Colors.green,
      );
    }

    if (hasAudio) {
      return Icon(
        Icons.volume_up,
        size: widget.size ?? 20,
        color: widget.color ?? Colors.blue,
      );
    }

    return Icon(
      Icons.volume_up_outlined,
      size: widget.size ?? 20,
      color: Colors.grey,
    );
  }

  String _getButtonLabel(TTSProvider ttsProvider, bool hasAudio, bool isPlaying, bool isGenerating) {
    if (isGenerating) return 'Generating...';
    if (isPlaying) return 'Playing...';
    if (hasAudio) return 'Play';
    return 'Generate';
  }

  Future<void> _handleTTSAction(TTSProvider ttsProvider) async {
    print('🔊 TTS Button tapped for word: ${widget.vocabularyItem.word}');
    print('🔊 TTS Provider current user ID: ${ttsProvider.currentUserId}');
    
    try {
      final pronunciations = ttsProvider.getPronunciations(widget.vocabularyItem.id);
      final hasAudio = pronunciations?.versions.containsKey(widget.version) ?? false;
      
      print('🔊 Has existing audio: $hasAudio');
      print('🔊 Pronunciations: $pronunciations');

      if (hasAudio) {
        print('🔊 Playing existing audio...');
        // Play existing audio
        await ttsProvider.playPronunciation(
          vocabEntryId: widget.vocabularyItem.id,
          version: widget.version,
        );
        widget.onPressed?.call();
      } else {
        print('🔊 Generating new pronunciations...');
        // Generate pronunciations first, then play
        final success = await ttsProvider.generatePronunciations(
          vocabularyItem: widget.vocabularyItem,
          versions: [widget.version],
        );

        print('🔊 Generation success: $success');
        if (success) {
          print('🔊 Waiting for generation to complete...');
          // Wait a moment for the generation to complete, then play
          await Future.delayed(const Duration(milliseconds: 500));
          print('🔊 Playing generated audio...');
          await ttsProvider.playPronunciation(
            vocabEntryId: widget.vocabularyItem.id,
            version: widget.version,
          );
          widget.onPressed?.call();
        } else {
          print('🔊 Generation failed, calling onError');
          widget.onError?.call();
        }
      }
    } catch (e) {
      print('🔊 TTS Error: $e');
      widget.onError?.call();
    }
  }
}

// TTS Control Panel for vocabulary items
class TTSControlPanel extends StatelessWidget {
  final VocabularyItem vocabularyItem;
  final List<String> versions;
  final bool showLabels;
  final VoidCallback? onError;

  const TTSControlPanel({
    super.key,
    required this.vocabularyItem,
    this.versions = const ['normal', 'slow'],
    this.showLabels = true,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TTSProvider>(
      builder: (context, ttsProvider, child) {
        final pronunciations = ttsProvider.getPronunciations(vocabularyItem.id);
        final hasAnyAudio = pronunciations != null && pronunciations.versions.isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.volume_up,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pronunciation',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  if (hasAnyAudio)
                    GestureDetector(
                      onTap: () => _deletePronunciations(ttsProvider),
                      child: Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Colors.red.shade400,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: versions.map((version) {
                  return TTSButton(
                    vocabularyItem: vocabularyItem,
                    version: version,
                    showLabel: showLabels,
                    onError: onError,
                  );
                }).toList(),
              ),
              if (ttsProvider.error != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Colors.red.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ttsProvider.error!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => ttsProvider.clearError(),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _deletePronunciations(TTSProvider ttsProvider) async {
    final success = await ttsProvider.deletePronunciations(vocabularyItem.id);
    if (!success) {
      onError?.call();
    }
  }
}

// TTS Status Indicator
class TTSStatusIndicator extends StatelessWidget {
  final String vocabEntryId;
  final double? size;

  const TTSStatusIndicator({
    super.key,
    required this.vocabEntryId,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TTSProvider>(
      builder: (context, ttsProvider, child) {
        final pronunciations = ttsProvider.getPronunciations(vocabEntryId);
        final isGenerating = ttsProvider.isGeneratingFor(vocabEntryId);
        final isPlaying = ttsProvider.isPlayingFor(vocabEntryId);
        final hasAudio = pronunciations != null && pronunciations.versions.isNotEmpty;

        if (isGenerating) {
          return SizedBox(
            width: size ?? 16,
            height: size ?? 16,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          );
        }

        if (isPlaying) {
          return Icon(
            Icons.volume_up,
            size: size ?? 16,
            color: Colors.green,
          );
        }

        if (hasAudio) {
          return Icon(
            Icons.volume_up,
            size: size ?? 16,
            color: Colors.blue,
          );
        }

        return Icon(
          Icons.volume_off,
          size: size ?? 16,
          color: Colors.grey,
        );
      },
    );
  }
}

// TTS Quota Display
class TTSQuotaDisplay extends StatelessWidget {
  final bool showDetails;

  const TTSQuotaDisplay({
    super.key,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TTSProvider>(
      builder: (context, ttsProvider, child) {
        final quota = ttsProvider.quota;
        final subscription = ttsProvider.subscription;

        if (quota == null) {
          return const SizedBox.shrink();
        }

        final usagePercentage = quota.monthlyCharacterLimit > 0 
            ? (quota.charactersUsedThisMonth / quota.monthlyCharacterLimit) * 100 
            : 0.0;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.data_usage,
                    size: 16,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TTS Usage',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const Spacer(),
                  if (subscription != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPlanColor(subscription.plan).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        subscription.plan.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getPlanColor(subscription.plan),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: usagePercentage / 100,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getUsageColor(usagePercentage),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${quota.charactersUsedThisMonth} / ${quota.monthlyCharacterLimit}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '${usagePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getUsageColor(usagePercentage),
                    ),
                  ),
                ],
              ),
              if (showDetails) ...[
                const SizedBox(height: 8),
                Text(
                  'Remaining: ${quota.charactersRemaining} characters',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (quota.voiceClonesLimit > 0)
                  Text(
                    'Voice clones: ${quota.voiceClonesUsed}/${quota.voiceClonesLimit}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getPlanColor(String plan) {
    switch (plan.toLowerCase()) {
      case 'premium':
        return Colors.purple;
      case 'pro':
        return Colors.blue;
      case 'basic':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getUsageColor(double percentage) {
    if (percentage >= 90) return Colors.red;
    if (percentage >= 75) return Colors.orange;
    return Colors.green;
  }
}

// TTS Voice Profile Selector
class TTSVoiceProfileSelector extends StatelessWidget {
  final String? selectedVoiceId;
  final Function(String?) onVoiceSelected;
  final bool showDefault;

  const TTSVoiceProfileSelector({
    super.key,
    this.selectedVoiceId,
    required this.onVoiceSelected,
    this.showDefault = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TTSProvider>(
      builder: (context, ttsProvider, child) {
        final voiceProfiles = ttsProvider.voiceProfiles;

        if (voiceProfiles.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voice Profile',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (showDefault)
                    _buildVoiceOption(
                      context,
                      null,
                      'Default',
                      selectedVoiceId == null,
                      () => onVoiceSelected(null),
                    ),
                  ...voiceProfiles.map((profile) => _buildVoiceOption(
                    context,
                    profile.voiceId,
                    profile.voiceName,
                    selectedVoiceId == profile.voiceId,
                    () => onVoiceSelected(profile.voiceId),
                  )),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoiceOption(
    BuildContext context,
    String? voiceId,
    String name,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.blue : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
