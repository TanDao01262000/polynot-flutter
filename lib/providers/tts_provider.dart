import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/tts_service.dart';
import '../models/vocabulary_item.dart';

class TTSProvider extends ChangeNotifier {
  // State management
  Map<String, TTSPronunciationResponse> _pronunciations = {};
  Map<String, bool> _isGenerating = {};
  Map<String, bool> _isPlaying = {};
  String? _currentPlayingAudio;
  String? _error;
  bool _isLoading = false;
  String? _currentUserId;
  
  // Voice profiles and subscription info
  List<TTSVoiceProfile> _voiceProfiles = [];
  TTSSubscription? _subscription;
  TTSQuota? _quota;
  
  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Getters
  Map<String, TTSPronunciationResponse> get pronunciations => _pronunciations;
  Map<String, bool> get isGenerating => _isGenerating;
  Map<String, bool> get isPlaying => _isPlaying;
  String? get currentPlayingAudio => _currentPlayingAudio;
  String? get error => _error;
  bool get isLoading => _isLoading;
  String? get currentUserId => _currentUserId;
  List<TTSVoiceProfile> get voiceProfiles => _voiceProfiles;
  TTSSubscription? get subscription => _subscription;
  TTSQuota? get quota => _quota;

  // Check if pronunciations exist for a vocabulary item
  bool hasPronunciations(String vocabEntryId) {
    return _pronunciations.containsKey(vocabEntryId);
  }

  // Get pronunciations for a vocabulary item
  TTSPronunciationResponse? getPronunciations(String vocabEntryId) {
    return _pronunciations[vocabEntryId];
  }

  // Check if currently generating pronunciations for a vocabulary item
  bool isGeneratingFor(String vocabEntryId) {
    return _isGenerating[vocabEntryId] ?? false;
  }

  // Check if currently playing audio for a vocabulary item
  bool isPlayingFor(String vocabEntryId) {
    return _isPlaying[vocabEntryId] ?? false;
  }

  // Set current user ID for authenticated requests
  void setCurrentUserId(String userId) {
    print('🔊 TTSProvider: Setting current user ID: ${userId.substring(0, 20)}...');
    _currentUserId = userId;
    notifyListeners();
  }

  // Clear current user ID
  void clearCurrentUserId() {
    _currentUserId = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Generate pronunciations for a vocabulary item
  Future<bool> generatePronunciations({
    required VocabularyItem vocabularyItem,
    List<String> versions = const ['normal', 'slow'],
    String language = 'en',
  }) async {
    print('🔊 TTSProvider.generatePronunciations called for: ${vocabularyItem.word}');
    print('🔊 TTSProvider current user ID: $_currentUserId');
    
    if (_currentUserId == null) {
      print('🔊 TTSProvider: User not authenticated');
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    final vocabEntryId = vocabularyItem.id;
    _isGenerating[vocabEntryId] = true;
    _error = null;
    notifyListeners();

    try {
      final response = await TTSService.generatePronunciations(
        vocabEntryId: vocabEntryId,
        text: vocabularyItem.word,
        language: language,
        versions: versions,
        userToken: _currentUserId,
      );

      if (response.success) {
        // Fetch the generated pronunciations
        await _fetchPronunciations(vocabEntryId);
        return true;
      } else {
        _error = 'Failed to generate pronunciations: ${response.message}';
        return false;
      }
    } catch (e) {
      _error = 'Error generating pronunciations: $e';
      return false;
    } finally {
      _isGenerating[vocabEntryId] = false;
      notifyListeners();
    }
  }

  // Ensure pronunciations exist for a vocabulary item
  Future<bool> ensurePronunciations({
    required String vocabEntryId,
    List<String> versions = const ['normal', 'slow'],
  }) async {
    if (_currentUserId == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isGenerating[vocabEntryId] = true;
    _error = null;
    notifyListeners();

    try {
      final response = await TTSService.ensurePronunciations(
        vocabEntryId: vocabEntryId,
        versions: versions,
        userToken: _currentUserId,
      );

      if (response.success) {
        // Fetch the pronunciations
        await _fetchPronunciations(vocabEntryId);
        return true;
      } else {
        _error = 'Failed to ensure pronunciations: ${response.message}';
        return false;
      }
    } catch (e) {
      _error = 'Error ensuring pronunciations: $e';
      return false;
    } finally {
      _isGenerating[vocabEntryId] = false;
      notifyListeners();
    }
  }

  // Fetch pronunciations for a vocabulary item
  Future<bool> _fetchPronunciations(String vocabEntryId) async {
    try {
      final response = await TTSService.getPronunciations(
        vocabEntryId: vocabEntryId,
        userToken: _currentUserId,
      );

      _pronunciations[vocabEntryId] = response;
      return true;
    } catch (e) {
      _error = 'Error fetching pronunciations: $e';
      return false;
    }
  }

  // Load pronunciations for a vocabulary item
  Future<bool> loadPronunciations(String vocabEntryId) async {
    if (_currentUserId == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _fetchPronunciations(vocabEntryId);
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Batch generate pronunciations for multiple vocabulary items
  Future<Map<String, bool>> batchGeneratePronunciations({
    required List<String> vocabEntryIds,
    List<String> versions = const ['normal', 'slow'],
  }) async {
    if (_currentUserId == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return {};
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await TTSService.batchGeneratePronunciations(
        vocabEntryIds: vocabEntryIds,
        versions: versions,
        userToken: _currentUserId,
      );

      final results = <String, bool>{};
      
      if (response.success) {
        // Process results and fetch pronunciations for successful items
        for (final entry in response.results.entries) {
          final vocabEntryId = entry.key;
          final result = entry.value;
          
          results[vocabEntryId] = result.success;
          
          if (result.success) {
            await _fetchPronunciations(vocabEntryId);
          }
        }
      }

      return results;
    } catch (e) {
      _error = 'Error batch generating pronunciations: $e';
      return {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Play pronunciation audio
  Future<void> playPronunciation({
    required String vocabEntryId,
    required String version,
  }) async {
    final pronunciations = _pronunciations[vocabEntryId];
    if (pronunciations == null) {
      _error = 'No pronunciations found for this vocabulary item';
      notifyListeners();
      return;
    }

    final pronunciationVersion = pronunciations.versions[version];
    if (pronunciationVersion == null) {
      _error = 'No pronunciation found for version: $version';
      notifyListeners();
      return;
    }

    // Stop any currently playing audio
    await stopCurrentAudio();

    _isPlaying[vocabEntryId] = true;
    _currentPlayingAudio = pronunciationVersion.audioUrl;
    notifyListeners();

    try {
      print('🔊 Playing audio from URL: ${pronunciationVersion.audioUrl}');
      
      // Play the audio using AudioPlayer
      await _audioPlayer.play(UrlSource(pronunciationVersion.audioUrl));
      
      // Listen for when playback completes
      _audioPlayer.onPlayerComplete.listen((event) {
        _isPlaying[vocabEntryId] = false;
        _currentPlayingAudio = null;
        notifyListeners();
      });
      
      // Listen for any errors
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.stopped || state == PlayerState.completed) {
          _isPlaying[vocabEntryId] = false;
          _currentPlayingAudio = null;
          notifyListeners();
        }
      });
      
    } catch (e) {
      print('🔊 Audio playback error: $e');
      _error = 'Error playing audio: $e';
    } finally {
      _isPlaying[vocabEntryId] = false;
      _currentPlayingAudio = null;
      notifyListeners();
    }
  }

  // Stop current audio
  Future<void> stopCurrentAudio() async {
    if (_currentPlayingAudio != null) {
      print('🔊 Stopping current audio');
      await _audioPlayer.stop();
      _currentPlayingAudio = null;
      
      // Clear all playing states
      _isPlaying.clear();
      notifyListeners();
    }
  }

  // Delete pronunciations for a vocabulary item
  Future<bool> deletePronunciations(String vocabEntryId) async {
    if (_currentUserId == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    try {
      final success = await TTSService.deletePronunciations(
        vocabEntryId: vocabEntryId,
        userToken: _currentUserId,
      );

      if (success) {
        _pronunciations.remove(vocabEntryId);
        _isGenerating.remove(vocabEntryId);
        _isPlaying.remove(vocabEntryId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = 'Error deleting pronunciations: $e';
      notifyListeners();
      return false;
    }
  }

  // Load voice profiles
  Future<bool> loadVoiceProfiles() async {
    if (_currentUserId == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _voiceProfiles = await TTSService.getVoiceProfiles(userToken: _currentUserId);
      return true;
    } catch (e) {
      _error = 'Error loading voice profiles: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load subscription information
  Future<bool> loadSubscription() async {
    if (_currentUserId == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subscription = await TTSService.getUserSubscription(userToken: _currentUserId);
      return true;
    } catch (e) {
      _error = 'Error loading subscription: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load quota information
  Future<bool> loadQuota() async {
    if (_currentUserId == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _quota = await TTSService.getTTSQuota(userToken: _currentUserId);
      return true;
    } catch (e) {
      _error = 'Error loading quota: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete voice profile
  Future<bool> deleteVoiceProfile(String voiceProfileId) async {
    if (_currentUserId == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    try {
      final success = await TTSService.deleteVoiceProfile(
        voiceProfileId: voiceProfileId,
        userToken: _currentUserId,
      );

      if (success) {
        _voiceProfiles.removeWhere((profile) => profile.id == voiceProfileId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = 'Error deleting voice profile: $e';
      notifyListeners();
      return false;
    }
  }

  // Clear all data
  void clearAll() {
    _pronunciations.clear();
    _isGenerating.clear();
    _isPlaying.clear();
    _currentPlayingAudio = null;
    _error = null;
    _isLoading = false;
    _voiceProfiles.clear();
    _subscription = null;
    _quota = null;
    notifyListeners();
  }

  // Check if user has TTS features available
  bool hasTTSFeatures() {
    return _subscription?.features.unlimitedTTS == true || 
           _quota?.charactersRemaining != null && _quota!.charactersRemaining > 0;
  }

  // Check if user can create voice clones
  bool canCreateVoiceClones() {
    return _subscription?.features.voiceCloning == true && 
           _quota?.voiceClonesRemaining != null && _quota!.voiceClonesRemaining > 0;
  }
}
