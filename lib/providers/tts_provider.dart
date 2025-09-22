import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_session/audio_session.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/tts_service.dart';
import '../models/vocabulary_item.dart';

class TTSProvider extends ChangeNotifier {
  // State management
  Map<String, TTSPronunciationResponse> _pronunciations = {};
  Map<String, bool> _isGenerating = {};
  
  // Audio cache directory
  Directory? _cacheDir;
  Map<String, bool> _isPlaying = {};
  String? _currentPlayingAudio;
  String? _error;
  bool _isLoading = false;
  String? _currentUserId;
  
  // Voice profiles and subscription info
  List<TTSVoiceProfile> _voiceProfiles = [];
  TTSSubscription? _subscription;
  TTSQuota? _quota;
  
  // Voice profile selection
  String? _selectedVoiceId;
  static const String _selectedVoiceKey = 'tts_selected_voice_id';
  
  // Audio player with proper configuration
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Constructor to initialize voice selection
  TTSProvider() {
    _initializeVoiceSelection();
  }

  // Initialize voice selection from storage
  Future<void> _initializeVoiceSelection() async {
    await loadSelectedVoiceId();
  }
  
  // Initialize audio cache directory
  Future<void> _initializeCacheDir() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/audio_cache');
      
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
        print('🔊 Created audio cache directory: ${_cacheDir!.path}');
      } else {
        print('🔊 Using existing audio cache directory: ${_cacheDir!.path}');
      }
    } catch (e) {
      print('🔊 Failed to initialize cache directory: $e');
      // Fallback to temporary directory
      _cacheDir = await getTemporaryDirectory();
    }
  }

  // Generate a cache filename based on URL hash and voice_id
  String _getCacheFileName(String url, {String? voiceId}) {
    // Create a simple hash from the URL using built-in hashCode
    final urlHash = url.hashCode.abs();
    
    // Extract a meaningful part from the URL for easier debugging
    final uri = Uri.parse(url);
    final pathParts = uri.pathSegments;
    final lastPart = pathParts.isNotEmpty ? pathParts.last : 'audio';
    
    // Clean the filename (remove special characters)
    final cleanPart = lastPart.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    
    // Include voice_id in filename to ensure different voices get different cache files
    if (voiceId != null && voiceId.isNotEmpty) {
      final cleanVoiceId = voiceId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      return '${cleanPart}_${cleanVoiceId}_${urlHash}.mp3';
    }
    
    return '${cleanPart}_${urlHash}.mp3';
  }

  // Check if audio file exists in cache
  Future<bool> _isAudioCached(String url, {String? voiceId}) async {
    if (_cacheDir == null) await _initializeCacheDir();
    
    final fileName = _getCacheFileName(url, voiceId: voiceId);
    final file = File('${_cacheDir!.path}/$fileName');
    final exists = await file.exists();
    
    if (exists) {
      print('🔊 Audio file found in cache: $fileName');
    } else {
      print('🔊 Audio file not in cache, will download: $fileName');
    }
    
    return exists;
  }

  // Get cached audio file path
  Future<String?> _getCachedAudioPath(String url, {String? voiceId}) async {
    if (_cacheDir == null) await _initializeCacheDir();
    
    final fileName = _getCacheFileName(url, voiceId: voiceId);
    final file = File('${_cacheDir!.path}/$fileName');
    
    if (await file.exists()) {
      print('🔊 Using cached audio file: ${file.path}');
      return file.path;
    }
    
    return null;
  }

  // Cache audio file
  Future<String> _cacheAudioFile(String url, List<int> audioBytes, {String? voiceId}) async {
    if (_cacheDir == null) await _initializeCacheDir();
    
    final fileName = _getCacheFileName(url, voiceId: voiceId);
    final file = File('${_cacheDir!.path}/$fileName');
    
    await file.writeAsBytes(audioBytes);
    print('🔊 Audio file cached to: ${file.path}');
    
    return file.path;
  }

  // Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    if (_cacheDir == null) await _initializeCacheDir();
    
    try {
      final files = await _cacheDir!.list().toList();
      int totalFiles = 0;
      int totalSize = 0;
      
      for (final file in files) {
        if (file is File && file.path.endsWith('.mp3')) {
          totalFiles++;
          totalSize += await file.length();
        }
      }
      
      return {
        'totalFiles': totalFiles,
        'totalSizeBytes': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'cachePath': _cacheDir!.path,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'totalFiles': 0,
        'totalSizeBytes': 0,
        'totalSizeMB': '0.00',
        'cachePath': _cacheDir?.path ?? 'Not initialized',
      };
    }
  }

  // Clear audio cache
  Future<void> clearAudioCache() async {
    if (_cacheDir == null) await _initializeCacheDir();
    
    try {
      final files = await _cacheDir!.list().toList();
      int deletedFiles = 0;
      
      for (final file in files) {
        if (file is File && file.path.endsWith('.mp3')) {
          await file.delete();
          deletedFiles++;
        }
      }
      
      print('🔊 Cleared audio cache: $deletedFiles files deleted');
    } catch (e) {
      print('🔊 Failed to clear audio cache: $e');
    }
  }

  // Clear ALL cache files (for debugging/testing)
  Future<void> clearAllCacheFiles() async {
    if (_cacheDir == null) await _initializeCacheDir();
    
    try {
      final files = await _cacheDir!.list().toList();
      int deletedFiles = 0;
      
      print('🔊 Starting cache cleanup...');
      print('🔊 Cache directory: ${_cacheDir!.path}');
      print('🔊 Found ${files.length} files in cache directory');
      
      for (final file in files) {
        if (file is File && file.path.endsWith('.mp3')) {
          await file.delete();
          deletedFiles++;
          print('🔊 Deleted cache file: ${file.path.split('/').last}');
        }
      }
      
      print('🔊 Cleared ALL $deletedFiles cache files');
      
      // Also clear the in-memory pronunciations to force regeneration
      _pronunciations.clear();
      _isGenerating.clear();
      _isPlaying.clear();
      print('🔊 Cleared in-memory pronunciations');
      
    } catch (e) {
      print('🔊 Failed to clear all cache files: $e');
    }
  }

  // Clear cache files that don't match the current voice
  Future<void> clearIncompatibleCacheFiles() async {
    if (_cacheDir == null) await _initializeCacheDir();
    if (_selectedVoiceId == null) return; // No voice selected, keep all files
    
    try {
      final files = await _cacheDir!.list().toList();
      int deletedFiles = 0;
      
      for (final file in files) {
        if (file is File && file.path.endsWith('.mp3')) {
          final fileName = file.path.split('/').last;
          
          // Check if this file was generated with a different voice
          // Files with voice_id in filename should match current voice
          if (fileName.contains('_') && fileName.contains('_mp3_')) {
            final parts = fileName.split('_mp3_');
            if (parts.length > 1) {
              final voicePart = parts[1].split('_')[0];
              if (voicePart != _selectedVoiceId) {
                await file.delete();
                deletedFiles++;
                print('🔊 Deleted incompatible cache file: $fileName (voice: $voicePart, current: $_selectedVoiceId)');
              }
            }
          }
        }
      }
      
      if (deletedFiles > 0) {
        print('🔊 Cleared $deletedFiles incompatible cache files');
      }
    } catch (e) {
      print('🔊 Failed to clear incompatible cache files: $e');
    }
  }

  // Initialize audio session for iOS compatibility (from working audio lab config)
  Future<void> _initializeAudioSession() async {
    try {
      final session = await AudioSession.instance;
      print('🔊 Audio session accessible');

      // Try multiple configurations like in the working audio lab
      try {
        await session.configure(const AudioSessionConfiguration.music());
        print('🔊 Music session configured');
      } catch (e) {
        print('🔊 Music session failed: $e');
      }

      try {
        await session.configure(const AudioSessionConfiguration.speech());
        print('🔊 Speech session configured');
      } catch (e) {
        print('🔊 Speech session failed: $e');
      }

      print('🔊 Audio session configuration completed');
    } catch (e) {
      print('🔊 Audio session configuration failed: $e');
    }
  }

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
  String? get selectedVoiceId => _selectedVoiceId;

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
    // Load voice selection when user ID is set
    loadSelectedVoiceId();
    notifyListeners();
  }

  // Clear current user ID
  void clearCurrentUserId() {
    _currentUserId = null;
    notifyListeners();
  }

  // ===== VOICE PROFILE SELECTION METHODS =====
  
  // Set selected voice profile
  Future<void> setSelectedVoiceId(String? voiceId) async {
    print('🔊 TTSProvider: setSelectedVoiceId called with: $voiceId');
    print('🔊 TTSProvider: Previous voice ID: $_selectedVoiceId');
    
    // If voice is changing, clear existing pronunciations to force regeneration
    if (_selectedVoiceId != voiceId) {
      print('🔊 TTSProvider: Voice changed, clearing existing pronunciations');
      _pronunciations.clear();
      _isGenerating.clear();
      _isPlaying.clear();
      // Clear audio cache to ensure new voice is used
      await clearAudioCache();
    }
    
    _selectedVoiceId = voiceId;
    
    // Save to persistent storage
    try {
      final prefs = await SharedPreferences.getInstance();
      if (voiceId != null) {
        await prefs.setString(_selectedVoiceKey, voiceId);
        print('🔊 TTSProvider: Selected voice saved to SharedPreferences: $voiceId');
      } else {
        await prefs.remove(_selectedVoiceKey);
        print('🔊 TTSProvider: Selected voice cleared from SharedPreferences');
      }
    } catch (e) {
      print('🔊 TTSProvider: Failed to save selected voice: $e');
    }
    
    print('🔊 TTSProvider: _selectedVoiceId is now: $_selectedVoiceId');
    notifyListeners();
  }

  // Load selected voice profile from storage
  Future<void> loadSelectedVoiceId() async {
    print('🔊 TTSProvider: loadSelectedVoiceId called');
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedVoiceId = prefs.getString(_selectedVoiceKey);
      print('🔊 TTSProvider: Retrieved from SharedPreferences: $savedVoiceId');
      if (savedVoiceId != null) {
        _selectedVoiceId = savedVoiceId;
        print('🔊 TTSProvider: Loaded selected voice: $savedVoiceId');
      } else {
        print('🔊 TTSProvider: No saved voice preference found');
      }
    } catch (e) {
      print('🔊 TTSProvider: Failed to load selected voice: $e');
    }
    print('🔊 TTSProvider: _selectedVoiceId after loading: $_selectedVoiceId');
  }

  // Get selected voice profile
  TTSVoiceProfile? getSelectedVoiceProfile() {
    if (_selectedVoiceId == null) return null;
    try {
      return _voiceProfiles.firstWhere((profile) => profile.voiceId == _selectedVoiceId);
    } catch (e) {
      print('🔊 TTSProvider: Selected voice profile not found: $_selectedVoiceId');
      return null;
    }
  }

  // Check if selected voice is available
  bool isSelectedVoiceAvailable() {
    if (_selectedVoiceId == null) return true; // Default voice is always available
    return _voiceProfiles.any((profile) => profile.voiceId == _selectedVoiceId);
  }

  // ===== VOICE CLONING METHODS =====
  
  // Create voice clone from audio files
  Future<TTSVoiceCloneResponse?> createVoiceClone({
    required String voiceName,
    required List<File> audioFiles,
    String? description,
  }) async {
    print('🔊 TTSProvider: createVoiceClone called');
    print('🔊 TTSProvider: Voice name: $voiceName');
    print('🔊 TTSProvider: Audio files count: ${audioFiles.length}');
    print('🔊 TTSProvider: Description: $description');
    print('🔊 TTSProvider: Current user ID: $_currentUserId');
    
    if (_currentUserId == null) {
      print('🔊 TTSProvider: User not authenticated');
      _error = 'User not authenticated';
      notifyListeners();
      return null;
    }

    print('🔊 TTSProvider: Setting loading state to true');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔊 TTSProvider: Calling TTSService.createVoiceClone...');
      
      // Log file details
      for (int i = 0; i < audioFiles.length; i++) {
        final file = audioFiles[i];
        print('🔊 TTSProvider: File $i: ${file.path}');
        try {
          final exists = await file.exists();
          final size = exists ? await file.length() : 0;
          print('🔊 TTSProvider: File $i exists: $exists, size: $size bytes');
        } catch (fileError) {
          print('🔊 TTSProvider: Error checking file $i: $fileError');
        }
      }
      
      final response = await TTSService.createVoiceClone(
        userId: _currentUserId!,
        voiceName: voiceName,
        audioFiles: audioFiles,
        description: description,
        userToken: _currentUserId,
      );

      print('🔊 TTSProvider: TTSService response: $response');
      print('🔊 TTSProvider: Response success: ${response.success}');
      print('🔊 TTSProvider: Response message: ${response.message}');

      if (response.success) {
        print('🔊 TTSProvider: Voice clone created successfully, reloading voice profiles...');
        // Reload voice profiles to include the new clone
        await loadVoiceProfiles();
        print('🔊 TTSProvider: Voice profiles reloaded');
        return response;
      } else {
        print('🔊 TTSProvider: Voice clone creation failed: ${response.message}');
        _error = 'Failed to create voice clone: ${response.message}';
        return null;
      }
    } catch (e, stackTrace) {
      print('🔊 TTSProvider: Exception in createVoiceClone: $e');
      print('🔊 TTSProvider: Stack trace: $stackTrace');
      _error = 'Error creating voice clone: $e';
      return null;
    } finally {
      print('🔊 TTSProvider: Setting loading state to false');
      _isLoading = false;
      notifyListeners();
    }
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
    print('🔊 TTSProvider: Selected voice ID: $_selectedVoiceId');
    print('🔊 TTSProvider: Available voice profiles: ${_voiceProfiles.map((p) => '${p.voiceName}(${p.voiceId})').join(', ')}');
    
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
      print('🔊 TTSProvider: Calling TTSService.generatePronunciations with voiceId: $_selectedVoiceId');
      final response = await TTSService.generatePronunciations(
        vocabEntryId: vocabEntryId,
        text: vocabularyItem.word,
        language: language,
        versions: versions,
        voiceId: _selectedVoiceId,
        userToken: _currentUserId,
      );

      if (response.success) {
        // Fetch the generated pronunciations
        await _fetchPronunciations(vocabEntryId);
        
        // Verify that the generated pronunciations use the correct voice
        final pronunciations = _pronunciations[vocabEntryId];
        if (pronunciations != null && _selectedVoiceId != null) {
          for (final version in pronunciations.versions.values) {
            if (version.voiceId != _selectedVoiceId) {
              print('🔊 TTSProvider: WARNING - Generated audio has voice_id: ${version.voiceId}, expected: $_selectedVoiceId');
            }
          }
        }
        
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
        voiceId: _selectedVoiceId,
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
        voiceId: _selectedVoiceId,
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

    // Clean the audio URL (remove trailing ? and other issues)
    String cleanUrl = pronunciationVersion.audioUrl;
    print('🔊 Original audio URL: $cleanUrl');
    print('🔊 URL length: ${cleanUrl.length}');
    print('🔊 URL ends with ?: ${cleanUrl.endsWith('?')}');
    
    if (cleanUrl.endsWith('?')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
      print('🔊 Cleaned audio URL: $cleanUrl');
    } else {
      print('🔊 No cleaning needed, URL is: $cleanUrl');
    }
    
    // Additional URL validation
    try {
      Uri.parse(cleanUrl);
      print('🔊 URL is valid');
    } catch (e) {
      print('🔊 URL validation failed: $e');
    }

    try {
      print('🔊 Playing audio from URL: ${pronunciationVersion.audioUrl}');
      print('🔊 Audio duration: ${pronunciationVersion.durationSeconds} seconds');
      
      // Initialize audio session for iOS compatibility
      await _initializeAudioSession();
      
      // Debug audio player state
      print('🔊 Audio player state before play: ${_audioPlayer.state}');
      
      // CACHED APPROACH: Check cache first, download if needed, then play
      String localFilePath;
      
      // Check if audio is already cached
      if (await _isAudioCached(cleanUrl, voiceId: pronunciationVersion.voiceId)) {
        // Use cached file
        localFilePath = (await _getCachedAudioPath(cleanUrl, voiceId: pronunciationVersion.voiceId))!;
        print('🔊 Using cached audio file');
      } else {
        // Download and cache the audio file
        print('🔊 Downloading and caching audio file...');
        
        final response = await http.get(Uri.parse(cleanUrl)).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print('🔊 Download timed out after 30 seconds');
            throw TimeoutException('Download timed out', const Duration(seconds: 30));
          },
        );
        
        if (response.statusCode != 200) {
          throw Exception('Failed to download audio: ${response.statusCode}');
        }
        
        print('🔊 Audio file downloaded successfully (${response.bodyBytes.length} bytes)');
        
        // Cache the file
        localFilePath = await _cacheAudioFile(cleanUrl, response.bodyBytes, voiceId: pronunciationVersion.voiceId);
      }
      
      // Now try to play the local file
      print('🔊 Playing audio file: $localFilePath');
      await _audioPlayer.play(DeviceFileSource(localFilePath)).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('🔊 Audio playback timed out after 15 seconds');
          throw TimeoutException('Audio playback timed out', const Duration(seconds: 15));
        },
      );
      
      print('🔊 Audio playback started successfully');
      
      // Set up completion listener (no cleanup needed for cached files)
      _audioPlayer.onPlayerComplete.listen((event) {
        print('🔊 Audio playback completed');
        _isPlaying[vocabEntryId] = false;
        _currentPlayingAudio = null;
        notifyListeners();
      });
      
      // Monitor player state changes
      _audioPlayer.onPlayerStateChanged.listen((state) {
        print('🔊 Player state changed: $state');
      });
      
    } catch (e) {
      print('🔊 Audio playback error: $e');
      _error = 'Error playing audio: $e';
      _isPlaying[vocabEntryId] = false;
      _currentPlayingAudio = null;
      notifyListeners();
    }
  }

  // Stop current audio
  Future<void> stopCurrentAudio() async {
    if (_currentPlayingAudio != null) {
      print('🔊 Stopping current audio');
      try {
        await _audioPlayer.stop();
      } catch (e) {
        print('🔊 Error stopping audio: $e');
      }
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
    print('🔊 TTSProvider: loadVoiceProfiles called');
    if (_currentUserId == null) {
      print('🔊 TTSProvider: User not authenticated for loading voice profiles');
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔊 TTSProvider: Calling TTSService.getVoiceProfiles...');
      _voiceProfiles = await TTSService.getVoiceProfiles(userToken: _currentUserId);
      print('🔊 TTSProvider: Loaded ${_voiceProfiles.length} voice profiles');
      for (final profile in _voiceProfiles) {
        print('🔊 TTSProvider: Voice profile: ${profile.voiceName} (${profile.voiceId})');
      }
      
      // Clear incompatible cache files after loading voice profiles
      await clearIncompatibleCacheFiles();
      
      return true;
    } catch (e) {
      print('🔊 TTSProvider: Error loading voice profiles: $e');
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
    _selectedVoiceId = null;
    notifyListeners();
  }

  // Clear pronunciations for a specific vocabulary item
  void clearPronunciationsForItem(String vocabEntryId) {
    _pronunciations.remove(vocabEntryId);
    _isGenerating.remove(vocabEntryId);
    _isPlaying.remove(vocabEntryId);
    print('🔊 TTSProvider: Cleared pronunciations for item: $vocabEntryId');
    notifyListeners();
  }

  // Force regeneration of pronunciations for a specific vocabulary item
  Future<bool> forceRegeneratePronunciations({
    required VocabularyItem vocabularyItem,
    List<String> versions = const ['normal', 'slow'],
    String language = 'en',
  }) async {
    print('🔊 TTSProvider: forceRegeneratePronunciations called for: ${vocabularyItem.word}');
    
    // Clear existing pronunciations first
    clearPronunciationsForItem(vocabularyItem.id);
    
    // Generate new pronunciations
    return await generatePronunciations(
      vocabularyItem: vocabularyItem,
      versions: versions,
      language: language,
    );
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

  // Dispose resources
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
