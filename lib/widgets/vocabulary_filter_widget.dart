import 'package:flutter/material.dart';

class VocabularyFilterWidget extends StatefulWidget {
  final Function(Map<String, String>) onFilterChanged;
  final List<String> availableUsers; // List of user names or IDs
  final Map<String, String> initialFilters;
  
  const VocabularyFilterWidget({
    super.key,
    required this.onFilterChanged,
    required this.availableUsers,
    this.initialFilters = const {},
  });

  @override
  State<VocabularyFilterWidget> createState() => _VocabularyFilterWidgetState();
}

class _VocabularyFilterWidgetState extends State<VocabularyFilterWidget> {
  String selectedLevel = 'flexible';
  List<String> selectedUsers = [];
  String selectedLanguage = 'all';
  
  final List<String> levelOptions = [
    'exact',
    'flexible', 
    'all',
    'A1',
    'A2', 
    'B1',
    'B2',
    'C1',
    'C2'
  ];
  
  final List<String> languageOptions = [
    'all',
    'English',
    'Korean',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Chinese',
    'Japanese'
  ];

  @override
  void initState() {
    super.initState();
    // Apply initial filters if provided
    selectedLevel = widget.initialFilters['level_filter'] ?? 'flexible';
    selectedLanguage = widget.initialFilters['language_filter'] ?? 'all';
    
    if (widget.initialFilters['user_filter'] != null) {
      selectedUsers = widget.initialFilters['user_filter']!.split(',');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.filter_list, color: Color(0xFF3498DB)),
              const SizedBox(width: 8),
              const Text(
                'Filter Friends\' Vocabulary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Color(0xFFE74C3C)),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Level Filter
          _buildFilterSection(
            title: 'Level Filter',
            icon: Icons.school,
            child: DropdownButtonFormField<String>(
              value: selectedLevel,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedLevel = newValue!;
                });
                _updateFilters();
              },
              items: levelOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(_getLevelDisplayName(value)),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // User Filter
          _buildFilterSection(
            title: 'Friends Filter',
            icon: Icons.people,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  if (selectedUsers.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: selectedUsers.map((user) => Chip(
                          label: Text(user),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              selectedUsers.remove(user);
                            });
                            _updateFilters();
                          },
                        )).toList(),
                      ),
                    ),
                  ],
                  if (widget.availableUsers.isNotEmpty)
                    ListTile(
                      title: Text(
                        selectedUsers.isEmpty 
                            ? 'Select friends to filter by'
                            : 'Add more friends',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: _showUserSelectionDialog,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'No friends available',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Language Filter
          _buildFilterSection(
            title: 'Language Filter',
            icon: Icons.language,
            child: DropdownButtonFormField<String>(
              value: selectedLanguage,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedLanguage = newValue!;
                });
                _updateFilters();
              },
              items: languageOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      if (value != 'all') ...[
                        Text(_getLanguageFlag(value)),
                        const SizedBox(width: 8),
                      ],
                      Text(value == 'all' ? 'All Languages' : value),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Filter Buttons
          _buildQuickFilters(),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Color(0xFF3498DB)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildQuickFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flash_on, size: 20, color: Color(0xFFF39C12)),
            const SizedBox(width: 8),
            const Text(
              'Quick Filters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickFilterChip('Easy Words', () => _setQuickFilter('A1,A2', 'all', [])),
            _buildQuickFilterChip('My Level', () => _setQuickFilter('exact', 'all', [])),
            _buildQuickFilterChip('All Levels', () => _setQuickFilter('all', 'all', [])),
            _buildQuickFilterChip('English Only', () => _setQuickFilter('flexible', 'English', [])),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickFilterChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFF3498DB).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xFF3498DB).withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF3498DB),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showUserSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Friends'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: widget.availableUsers.length,
            itemBuilder: (context, index) {
              final user = widget.availableUsers[index];
              final isSelected = selectedUsers.contains(user);
              
              return CheckboxListTile(
                title: Text(user),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedUsers.add(user);
                    } else {
                      selectedUsers.remove(user);
                    }
                  });
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateFilters();
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _setQuickFilter(String level, String language, List<String> users) {
    setState(() {
      selectedLevel = level;
      selectedLanguage = language;
      selectedUsers = users;
    });
    _updateFilters();
  }

  void _clearAllFilters() {
    setState(() {
      selectedLevel = 'flexible';
      selectedLanguage = 'all';
      selectedUsers = [];
    });
    _updateFilters();
  }

  void _updateFilters() {
    final filters = <String, String>{};
    
    if (selectedLevel != 'flexible') {
      filters['level_filter'] = selectedLevel;
    }
    
    if (selectedUsers.isNotEmpty) {
      filters['user_filter'] = selectedUsers.join(',');
    }
    
    if (selectedLanguage != 'all') {
      filters['language_filter'] = selectedLanguage;
    }
    
    widget.onFilterChanged(filters);
  }

  String _getLevelDisplayName(String level) {
    switch (level) {
      case 'exact': return 'My Level Only';
      case 'flexible': return 'Flexible Range (Recommended)';
      case 'all': return 'All Levels';
      default: return 'Level $level';
    }
  }

  String _getLanguageFlag(String language) {
    switch (language) {
      case 'English': return '🇺🇸';
      case 'Korean': return '🇰🇷';
      case 'Spanish': return '🇪🇸';
      case 'French': return '🇫🇷';
      case 'German': return '🇩🇪';
      case 'Italian': return '🇮🇹';
      case 'Chinese': return '🇨🇳';
      case 'Japanese': return '🇯🇵';
      default: return '🌍';
    }
  }
}


