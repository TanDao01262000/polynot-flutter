import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/smart_feed_provider.dart';

class SmartFilteringScreen extends StatefulWidget {
  final VoidCallback? onFiltersApplied;

  const SmartFilteringScreen({
    super.key,
    this.onFiltersApplied,
  });

  @override
  State<SmartFilteringScreen> createState() => _SmartFilteringScreenState();
}

class _SmartFilteringScreenState extends State<SmartFilteringScreen> {
  final List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  final List<String> _languages = [
    'English',
    'Spanish', 
    'French',
    'German',
    'Italian',
    'Chinese',
    'Japanese',
    'Korean',
    'Vietnamese'
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SmartFeedProvider>(
      builder: (context, smartFeedProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: const Text(
              'Smart Filtering',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton(
                onPressed: () => smartFeedProvider.resetToDefaults(),
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    color: Color(0xFF3498DB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  'Feed Customization',
                  'Personalize your feed experience',
                  Icons.tune,
                ),
                const SizedBox(height: 16),
                
                _buildToggleSetting(
                  'Include Level Peers',
                  'Show posts from users at your learning level',
                  smartFeedProvider.includeLevelPeers,
                  (value) => smartFeedProvider.updateIncludeLevelPeers(value),
                ),
                const SizedBox(height: 16),
                
                _buildToggleSetting(
                  'Include Language Peers',
                  'Show posts from users learning the same language',
                  smartFeedProvider.includeLanguagePeers,
                  (value) => smartFeedProvider.updateIncludeLanguagePeers(value),
                ),
                const SizedBox(height: 16),
                
                _buildToggleSetting(
                  'Include Trending Content',
                  'Show trending words and topics (may slow down loading)',
                  smartFeedProvider.includeTrending,
                  (value) => smartFeedProvider.updateIncludeTrending(value),
                ),
                const SizedBox(height: 24),
                
                _buildSectionHeader(
                  'Personalization',
                  'Control how personalized your feed is',
                  Icons.psychology,
                ),
                const SizedBox(height: 16),
                
                _buildPersonalizationSlider(smartFeedProvider),
                const SizedBox(height: 24),
                
                _buildSectionHeader(
                  'Filters',
                  'Filter content by level and language',
                  Icons.filter_list,
                ),
                const SizedBox(height: 16),
                
                _buildLevelFilter(smartFeedProvider),
                const SizedBox(height: 16),
                
                _buildLanguageFilter(smartFeedProvider),
                const SizedBox(height: 32),
                
                _buildApplyButton(smartFeedProvider),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF3498DB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF3498DB),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7F8C8D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSetting(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3498DB),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizationSlider(SmartFeedProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology,
                color: Color(0xFF3498DB),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Personalization Strength',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(provider.personalizationScore * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3498DB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getPersonalizationDescription(provider.personalizationScore),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF3498DB),
              inactiveTrackColor: const Color(0xFF3498DB).withOpacity(0.2),
              thumbColor: const Color(0xFF3498DB),
              overlayColor: const Color(0xFF3498DB).withOpacity(0.2),
            ),
            child: Slider(
              value: provider.personalizationScore,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: (value) {
                provider.updatePersonalizationScore(value);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chronological',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7F8C8D),
                ),
              ),
              const Text(
                'Highly Personalized',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7F8C8D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelFilter(SmartFeedProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Level',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Show only content from specific learning levels',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: provider.selectedLevel,
            decoration: InputDecoration(
              hintText: 'All Levels',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFBDC3C7)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF3498DB)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All Levels'),
              ),
              ..._levels.map((level) => DropdownMenuItem<String>(
                value: level,
                child: Text(level),
              )),
            ],
            onChanged: (value) {
              provider.updateSelectedLevel(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageFilter(SmartFeedProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Language',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Show only content for specific languages',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: provider.selectedLanguage,
            decoration: InputDecoration(
              hintText: 'All Languages',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFBDC3C7)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF3498DB)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All Languages'),
              ),
              ..._languages.map((language) => DropdownMenuItem<String>(
                value: language,
                child: Text(language),
              )),
            ],
            onChanged: (value) {
              provider.updateSelectedLanguage(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton(SmartFeedProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _applySettings(provider),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3498DB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Apply Smart Filtering',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getPersonalizationDescription(double score) {
    if (score < 0.3) {
      return 'More chronological feed with recent posts first';
    } else if (score < 0.7) {
      return 'Balanced mix of personalized and chronological content';
    } else {
      return 'Highly personalized feed based on your learning patterns';
    }
  }

        void _applySettings(SmartFeedProvider provider) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Smart filtering applied: '
                'Level Peers: ${provider.includeLevelPeers ? "On" : "Off"}, '
                'Language Peers: ${provider.includeLanguagePeers ? "On" : "Off"}, '
                'Trending: ${provider.includeTrending ? "On" : "Off"}, '
                'Personalization: ${(provider.personalizationScore * 100).toInt()}%'
              ),
              backgroundColor: const Color(0xFF27AE60),
              duration: const Duration(seconds: 3),
            ),
          );

          // Trigger feed refresh if callback is provided
          widget.onFiltersApplied?.call();

          Navigator.pop(context);
        }
}