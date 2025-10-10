import 'package:flutter/foundation.dart';

class SmartFeedProvider extends ChangeNotifier {
  // Smart filtering settings
  bool _includeLevelPeers = true;
  bool _includeLanguagePeers = true;
  bool _includeTrending = false;
  double _personalizationScore = 0.7;
  String? _selectedLevel;
  String? _selectedLanguage;

  // Getters
  bool get includeLevelPeers => _includeLevelPeers;
  bool get includeLanguagePeers => _includeLanguagePeers;
  bool get includeTrending => _includeTrending;
  double get personalizationScore => _personalizationScore;
  String? get selectedLevel => _selectedLevel;
  String? get selectedLanguage => _selectedLanguage;

  // Update methods
  void updateIncludeLevelPeers(bool value) {
    _includeLevelPeers = value;
    notifyListeners();
  }

  void updateIncludeLanguagePeers(bool value) {
    _includeLanguagePeers = value;
    notifyListeners();
  }

  void updateIncludeTrending(bool value) {
    _includeTrending = value;
    notifyListeners();
  }

  void updatePersonalizationScore(double value) {
    _personalizationScore = value;
    notifyListeners();
  }

  void updateSelectedLevel(String? value) {
    _selectedLevel = value;
    notifyListeners();
  }

  void updateSelectedLanguage(String? value) {
    _selectedLanguage = value;
    notifyListeners();
  }

  // Apply all settings at once
  void applySettings({
    bool? includeLevelPeers,
    bool? includeLanguagePeers,
    bool? includeTrending,
    double? personalizationScore,
    String? selectedLevel,
    String? selectedLanguage,
  }) {
    if (includeLevelPeers != null) _includeLevelPeers = includeLevelPeers;
    if (includeLanguagePeers != null) _includeLanguagePeers = includeLanguagePeers;
    if (includeTrending != null) _includeTrending = includeTrending;
    if (personalizationScore != null) _personalizationScore = personalizationScore;
    if (selectedLevel != null) _selectedLevel = selectedLevel;
    if (selectedLanguage != null) _selectedLanguage = selectedLanguage;
    
    notifyListeners();
  }

  // Reset to defaults
  void resetToDefaults() {
    _includeLevelPeers = true;
    _includeLanguagePeers = true;
    _includeTrending = false;
    _personalizationScore = 0.7;
    _selectedLevel = null;
    _selectedLanguage = null;
    notifyListeners();
  }

  // Check if settings have been modified from defaults
  bool get hasCustomSettings {
    return !_includeLevelPeers ||
           !_includeLanguagePeers ||
           _includeTrending ||
           _personalizationScore != 0.7 ||
           _selectedLevel != null ||
           _selectedLanguage != null;
  }
}