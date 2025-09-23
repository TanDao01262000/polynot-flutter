import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard_models.dart';
import '../providers/flashcard_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/flashcard_widgets.dart';
import 'flashcard_stats_screen.dart';

// Main flashcard screen with navigation
class FlashcardMainScreen extends StatefulWidget {
  const FlashcardMainScreen({super.key});

  @override
  State<FlashcardMainScreen> createState() => _FlashcardMainScreenState();
}

class _FlashcardMainScreenState extends State<FlashcardMainScreen> {
  int _selectedIndex = 0;
  bool _hasAutoNavigated = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, FlashcardProvider>(
      builder: (context, userProvider, flashcardProvider, child) {
        // Auto-navigate to study screen when session is first created (only once)
        if (flashcardProvider.isSessionActive && !_hasAutoNavigated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _selectedIndex = 1;
              _hasAutoNavigated = true;
            });
          });
        }
        
        // Reset auto-navigation flag when session ends
        if (!flashcardProvider.isSessionActive && _hasAutoNavigated) {
          _hasAutoNavigated = false;
        }
        if (!userProvider.isLoggedIn) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Flashcards'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Login Required',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please login to access flashcard features',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Flashcards'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: const [
              FlashcardHomeScreen(),
              FlashcardStudyScreen(),
              FlashcardStatsScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              // Allow switching to any tab, but show a gentle reminder if leaving study during active session
              if (flashcardProvider.isSessionActive && _selectedIndex == 1 && index != 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Session is still active - you can return to Study tab anytime'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
              setState(() => _selectedIndex = index);
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Icon(Icons.school),
                    if (flashcardProvider.isSessionActive)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Study',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: 'Stats',
              ),
            ],
          ),
        );
      },
    );
  }

}

// Home screen for creating sessions
class FlashcardHomeScreen extends StatefulWidget {
  const FlashcardHomeScreen({super.key});

  @override
  State<FlashcardHomeScreen> createState() => _FlashcardHomeScreenState();
}

class _FlashcardHomeScreenState extends State<FlashcardHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final flashcardProvider = context.read<FlashcardProvider>();
      
      if (userProvider.isLoggedIn && userProvider.sessionToken != null) {
        flashcardProvider.initializeWithUser(userProvider.sessionToken!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashcardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingSession) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Flashcard Study',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your study mode and start learning vocabulary',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              
              // Quick Start Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF667eea).withOpacity(0.1),
                      const Color(0xFF764ba2).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF667eea).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.flash_on,
                          color: const Color(0xFF667eea),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Quick Start',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Start with default settings or customize your session below',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _createCustomSession(provider);
                        },
                        icon: const Icon(Icons.flash_on),
                        label: const Text('Quick Start (Default Settings)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Custom Session Configuration
              _buildCustomSessionConfiguration(context, provider),
              
              const SizedBox(height: 24),
              
              // Recent Sessions Section
              if (provider.sessions.isNotEmpty) ...[
                Text(
                  'Recent Sessions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.sessions.take(5).length,
                    itemBuilder: (context, index) {
                      final session = provider.sessions[index];
                      return GestureDetector(
                        onTap: session.isActive ? () => _resumeSession(provider, session) : null,
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: session.isActive ? Colors.blue.shade50 : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: session.isActive ? Colors.blue.shade200 : Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.sessionName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${session.totalCards} cards • ${session.studyMode}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            if (session.isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Paused',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              Text(
                                'Completed',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // View All Sessions Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _loadExistingSessions(provider);
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('View All Sessions'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _resetForNewSession() {
    // This method is called when starting a new session from the home screen
    // The actual UI state reset will happen in the study screen
    print('🔄 STARTING NEW SESSION - UI state will be reset in study screen');
  }


  Future<void> _loadExistingSessions(FlashcardProvider provider) async {
    try {
      await provider.loadSessions();
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Existing Sessions'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: provider.sessions.length,
                itemBuilder: (context, index) {
                  final session = provider.sessions[index];
                  return ListTile(
                    title: Text(session.sessionName),
                    subtitle: Text('${session.totalCards} cards • ${session.studyMode}'),
                    trailing: session.isActive 
                        ? const Icon(Icons.play_circle, color: Colors.green)
                        : const Icon(Icons.check_circle, color: Colors.grey),
                    onTap: () async {
                      Navigator.pop(context);
                      if (session.isActive) {
                        // Resume the paused session
                        await provider.resumeSession(session);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Resumed session: ${session.sessionName}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load sessions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCustomSessionConfiguration(BuildContext context, FlashcardProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                Icons.settings,
                color: Colors.blue[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Session Configuration',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Customize your study session to match your learning goals',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          
          // Number of Cards Slider
          _buildCardCountSlider(context, provider),
          const SizedBox(height: 20),
          
          // Study Mode Dropdown
          _buildStudyModeDropdown(context, provider),
          const SizedBox(height: 20),
          
          // Level Selection
          _buildLevelSelector(context, provider),
          const SizedBox(height: 24),
          
          // Start Session Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: provider.isLoadingSession ? null : () {
                _createCustomSession(provider);
              },
              icon: provider.isLoadingSession 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(provider.isLoadingSession ? 'Creating Session...' : 'Start Study Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardCountSlider(BuildContext context, FlashcardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Number of Cards',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${provider.selectedCardCount ?? 10}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.blue[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: (provider.selectedCardCount ?? 10).toDouble(),
          min: 3,
          max: 50,
          divisions: 47,
          activeColor: Colors.blue[600],
          inactiveColor: Colors.grey[300],
          onChanged: (value) {
            provider.setSelectedCardCount(value.round());
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('3', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text('50', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildStudyModeDropdown(BuildContext context, FlashcardProvider provider) {
    final studyModes = [
      {'value': 'practice', 'label': 'Practice Mode', 'description': 'Show word, guess definition'},
      {'value': 'review', 'label': 'Review Mode', 'description': 'Show definition, guess word'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Study Mode',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '2 modes available',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.selectedStudyMode ?? 'practice',
              isExpanded: true,
              items: studyModes.map((mode) {
                return DropdownMenuItem<String>(
                  value: mode['value']!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        mode['label']!,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        mode['description']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.setSelectedStudyMode(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelSelector(BuildContext context, FlashcardProvider provider) {
    final levels = [
      {'value': 'mixed', 'label': 'Mixed - All Levels', 'color': Colors.blue, 'isSpecial': true},
      {'value': 'A1', 'label': 'A1 - Beginner', 'color': Colors.green, 'isSpecial': false},
      {'value': 'A2', 'label': 'A2 - Elementary', 'color': Colors.lightGreen, 'isSpecial': false},
      {'value': 'B1', 'label': 'B1 - Intermediate', 'color': Colors.orange, 'isSpecial': false},
      {'value': 'B2', 'label': 'B2 - Upper Intermediate', 'color': Colors.deepOrange, 'isSpecial': false},
      {'value': 'C1', 'label': 'C1 - Advanced', 'color': Colors.red, 'isSpecial': false},
      {'value': 'C2', 'label': 'C2 - Proficient', 'color': Colors.purple, 'isSpecial': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language Level',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the language proficiency level for your vocabulary',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.selectedLevel ?? 'B1',
              isExpanded: true,
              items: levels.map((level) {
                final isSpecial = level['isSpecial'] as bool;
                return DropdownMenuItem<String>(
                  value: level['value'] as String,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: level['color'] as Color,
                          shape: isSpecial ? BoxShape.rectangle : BoxShape.circle,
                          borderRadius: isSpecial ? BorderRadius.circular(2) : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          level['label'] as String,
                          style: isSpecial 
                            ? const TextStyle(fontWeight: FontWeight.w600)
                            : null,
                        ),
                      ),
                      if (isSpecial)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'All Levels',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.setSelectedLevel(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createCustomSession(FlashcardProvider provider) async {
    // Reset UI state for new session
    _resetForNewSession();
    
    final selectedLevel = provider.selectedLevel ?? 'B1';
    final request = CreateSessionRequest(
      sessionName: 'Custom Study Session',
      sessionType: 'daily_review',
      studyMode: provider.selectedStudyMode ?? 'practice',
      level: selectedLevel == 'mixed' ? null : selectedLevel,
      maxCards: provider.selectedCardCount ?? 10,
      includeReviewed: false,
      includeFavorites: false,
      smartSelection: true,
    );

    final response = await provider.createSession(request);
    
    if (response == null || !response.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.sessionError ?? 'Failed to create session'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    // Navigation is handled automatically by the main screen
  }

  Future<void> _resumeSession(FlashcardProvider provider, FlashcardSession session) async {
    try {
      await provider.resumeSession(session);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resumed session: ${session.sessionName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resume session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Enhanced study screen following backend guide
class FlashcardStudyScreen extends StatefulWidget {
  const FlashcardStudyScreen({super.key});

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  final FocusNode _answerFocusNode = FocusNode();
  
  bool _isFlipped = false;
  bool _showDifficultyRating = false;
  bool _isSubmittingAnswer = false;
  bool _isLoadingNextCard = false;
  bool _canProceedToNext = false;
  DateTime? _startTime;
  // String? _selectedDifficultyRating; // Commented out - not using difficulty rating
  String _userAnswer = '';
  FlashcardAnswerResult? _lastAnswerResult;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    
    // Auto-focus on answer input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _answerFocusNode.requestFocus();
    });
  }

  void _resetForNextCard() {
    setState(() {
      _userAnswer = ''; // Clear the user answer
      _isFlipped = false;
      // _showDifficultyRating = false; // Commented out - not using difficulty rating
      // _selectedDifficultyRating = null; // Commented out - not using difficulty rating
      _lastAnswerResult = null;
      _canProceedToNext = false; // Reset button state for new card
      _isLoadingNextCard = false; // Reset loading state for new card
      _startTime = DateTime.now();
    });
    
    // Auto-focus on answer input for next card
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _answerFocusNode.requestFocus();
    });
  }

  void _resetForNewSession() {
    setState(() {
      _userAnswer = ''; // Clear the user answer
      _isFlipped = false;
      _lastAnswerResult = null; // Reset session completion state
      _canProceedToNext = false; // Reset button state
      _isSubmittingAnswer = false; // Reset submission state
      _isLoadingNextCard = false; // Reset loading state
      _startTime = DateTime.now();
    });
    
    print('🔄 RESET FOR NEW SESSION - cleared all UI state');
  }

  @override
  void dispose() {
    _answerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashcardProvider>(
      builder: (context, provider, child) {
        // Check if we have an active session
        if (!provider.hasActiveSession) {
          return _buildNoSession();
        }

        // Check if we're loading a card
        if (provider.isLoadingCard) {
          return const Center(child: CircularProgressIndicator());
        }

        // Don't automatically show completion screen - let user see their final answer result first
        // The completion screen will be shown when they click "View Results" button

        // Check if we have a current card
        if (provider.currentCard == null) {
          return _buildNoSession();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(provider.currentSession?.sessionName ?? 'Study'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _showExitSessionDialog(provider),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: () => _showEndSessionDialog(provider),
                tooltip: 'End Session',
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showSessionInfo(provider),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Enhanced Progress Indicator
                if (provider.sessionStats != null)
                  FlashcardProgressIndicator(
                    currentCard: provider.sessionStats!.totalAnswered,
                    totalCards: provider.currentCard!.totalCards,
                    accuracy: provider.sessionStats!.accuracyPercentage,
                  ),
                const SizedBox(height: 20),

                // Enhanced Flashcard Widget
                Expanded(
                  child: FlashcardWidget(
                    card: provider.currentCard!,
                    studyMode: provider.currentSession?.studyMode ?? 'practice',
                    onFlip: () {
                      setState(() {
                        _isFlipped = !_isFlipped;
                      });
                    },
                    isFlipped: _isFlipped,
                  ),
                ),
                const SizedBox(height: 20),

                // Answer Input Section - Always visible
                if (!_showDifficultyRating) ...[
                  FlashcardAnswerInput(
                    studyMode: provider.currentSession?.studyMode ?? 'practice',
                    onSubmit: () => _submitAnswer(provider),
                    onAnswerChanged: (answer) {
                      setState(() {
                        _userAnswer = answer;
                      });
                    },
                    isLoading: _isSubmittingAnswer || _canProceedToNext,
                  ),
                  const SizedBox(height: 16),
                ],

                // Difficulty Rating Section (commented out for now)
                // if (_showDifficultyRating && _lastAnswerResult != null) ...[
                //   DifficultyRatingSelector(
                //     ratings: provider.difficultyRatings,
                //     selectedRating: _selectedDifficultyRating,
                //     onRatingSelected: (rating) {
                //       setState(() {
                //         _selectedDifficultyRating = rating;
                //       });
                //       _proceedToNextCard(provider);
                //     },
                //     isLoading: _isSubmittingAnswer,
                //   ),
                // ],

                // Feedback and Next Card Buttons
                const SizedBox(height: 16),
                // Always show buttons - no visibility constraint
                Column(
                    children: [
                      
                      // Session Complete Message
                      if (_lastAnswerResult?.sessionComplete == true) ...[
                        // Debug: Print session completion status
                        Builder(
                          builder: (context) {
                            print('🎯 UI: Showing session complete message');
                            return const SizedBox.shrink();
                          },
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.celebration,
                                color: Colors.green.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Session Complete! Tap "View Results" to see your performance.',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      // Dual Button System: Show Details + Next Card/View Stats
                      Row(
                        children: [
                          // Show Details Button (always available)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: (_isSubmittingAnswer || !_canProceedToNext) ? null : () => _showDetailedFeedback(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue, width: 2),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Show Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Next Card or View Stats Button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: (_isSubmittingAnswer || _isLoadingNextCard || !_canProceedToNext) ? null : () => _proceedToNextCard(provider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _lastAnswerResult?.sessionComplete == true 
                                    ? Colors.green 
                                    : Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoadingNextCard
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Builder(
                                      builder: (context) {
                                        final isComplete = _lastAnswerResult?.sessionComplete == true;
                                        print('🎯 UI: Button text - sessionComplete: $isComplete');
                                        return Text(
                                          isComplete ? 'View Stats' : 'Next Card',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                // Feedback shown via SnackBar (no inline feedback to avoid layout shift)
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitAnswer(FlashcardProvider provider) async {
    if (_userAnswer.trim().isEmpty) return;
    
    // Prevent multiple submissions - check immediately
    if (_isSubmittingAnswer) {
      print('🚫 PREVENTING DOUBLE SUBMIT - already submitting');
      return;
    }

    // Set flag immediately to prevent race condition
    _isSubmittingAnswer = true;
    print('🚀 STARTING SUBMIT - _isSubmittingAnswer set to true immediately');
    
    setState(() {
      // State is already set above, this just triggers rebuild
    });
    
    // Calculate response time
    final responseTime = DateTime.now().difference(_startTime!).inSeconds.toDouble();
    
    // Create answer object (without difficulty rating - that comes after)
           final answer = FlashcardAnswer(
             userAnswer: _userAnswer.trim(),
             responseTimeSeconds: responseTime,
             hintsUsed: 0,
             difficultyRating: 'medium', // Default difficulty rating
           );
    
    try {
      final result = await provider.submitAnswer(answer);
      
      if (result != null && result.success) {
        print('✅ RESULT: correct=${result.correct}, sessionComplete=${result.sessionComplete}');
        print('📊 SESSION STATS: ${result.sessionStats.correctAnswers}/${result.sessionStats.correctAnswers + result.sessionStats.incorrectAnswers} correct, ${result.sessionStats.cardsRemaining} remaining');
        
        setState(() {
          _lastAnswerResult = result;
          _isFlipped = true;
          _isSubmittingAnswer = false;
          _canProceedToNext = true;
        });
        
        // Show immediate feedback
        _showFeedback(result.correct);
        
        // Check if session is complete
        if (result.sessionComplete) {
          print('🎯 SESSION COMPLETE - last card answered, user can review result');
          // Don't show completion dialog immediately, let user review the result
          // The completion dialog will be shown when they try to proceed to next card
        } else {
          // Answer submitted successfully - feedback shown
          print('✅ ANSWER SUBMITTED - feedback shown');
        }
      } else {
        setState(() {
          _isSubmittingAnswer = false;
        });
        _showError(provider.sessionError ?? 'Failed to submit answer');
      }
    } catch (e) {
      setState(() {
        _isSubmittingAnswer = false;
      });
      _showError('Error: $e');
    }
  }

  Future<void> _proceedToNextCard(FlashcardProvider provider) async {
    print('🔄 PROCEEDING TO NEXT CARD');

    // Check if session is complete from the last answer result
    if (_lastAnswerResult != null && _lastAnswerResult!.sessionComplete) {
      print('🎯 SESSION COMPLETE - showing completion screen');
      _showSessionComplete(provider, _lastAnswerResult!);
      return;
    }

    setState(() {
      _isLoadingNextCard = true;
    });

    // Get the next card (answer was already submitted with difficulty rating)
    print('➡️ FETCHING NEXT CARD...');
    try {
      await provider.refreshCurrentCard();
      
      // If we got a card, show it
      if (provider.currentCard != null) {
        print('✅ NEXT CARD LOADED: ${provider.currentCard?.word}');
        
        // Reset UI state for the new card immediately
        if (mounted) {
          _resetForNextCard();
        }
      } else {
        // No more cards - session is complete
        print('🎯 NO MORE CARDS - SESSION COMPLETE');
        if (_lastAnswerResult != null) {
          _showSessionComplete(provider, _lastAnswerResult!);
        } else {
          // If no last answer result, just end the session
          provider.endSession();
        }
      }
    } catch (e) {
      print('❌ ERROR LOADING NEXT CARD: $e');
      // If we can't load the next card, assume session is complete
      print('🎯 ERROR LOADING CARD - ASSUMING SESSION COMPLETE');
      if (_lastAnswerResult != null) {
        _showSessionComplete(provider, _lastAnswerResult!);
      } else {
        // If no last answer result, just end the session
        provider.endSession();
      }
    }
    
    setState(() {
      _isLoadingNextCard = false;
    });
  }


  void _showSessionInfo(FlashcardProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (provider.currentSession != null) ...[
              Text('Name: ${provider.currentSession!.sessionName}'),
              Text('Mode: ${provider.currentSession!.studyMode}'),
              Text('Type: ${provider.currentSession!.sessionType}'),
              Text('Total Cards: ${provider.currentSession!.totalCards}'),
              if (provider.sessionStats != null) ...[
                const SizedBox(height: 8),
                const Divider(),
                Text('Correct: ${provider.sessionStats!.correctAnswers}'),
                Text('Incorrect: ${provider.sessionStats!.incorrectAnswers}'),
                Text('Accuracy: ${provider.sessionStats!.accuracyPercentage.toStringAsFixed(1)}%'),
                Text('Remaining: ${provider.sessionStats!.cardsRemaining}'),
              ],
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showExitSessionDialog(FlashcardProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.pause_circle, color: Colors.blue),
            SizedBox(width: 8),
            Text('Exit Session'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What would you like to do with your current session?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              '• Pause: Save progress and resume later\n'
              '• End: Complete the session permanently\n'
              '• Cancel: Continue studying',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              provider.pauseSession();
              // Navigate to flashcard home screen instead of just popping
              Navigator.pushReplacementNamed(context, '/flashcards');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
            ),
            child: const Text('Pause Session'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              provider.endSession();
              // Navigate to flashcard home screen instead of just popping
              Navigator.pushReplacementNamed(context, '/flashcards');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  void _showEndSessionDialog(FlashcardProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.stop_circle, color: Colors.orange),
            SizedBox(width: 8),
            Text('End Session'),
          ],
        ),
        content: const Text(
          'Are you sure you want to end this session? Your progress will be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              provider.endSession();
              // Navigate to flashcard home screen instead of just popping
              Navigator.pushReplacementNamed(context, '/flashcards');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  void _showFeedback(bool isCorrect) {
    if (_lastAnswerResult == null) return;
    
    final result = _lastAnswerResult!;
    final confidenceScore = result.confidenceScore;
    final confidenceText = _getConfidenceText(confidenceScore);
    
    // Parse feedback to get a brief learning tip
    final feedbackContent = FeedbackContent.fromFeedback(result.feedback);
    final briefTip = feedbackContent.learningTip?.split('.')[0]; // Get first sentence
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
                Expanded(
                  child: Text(
              isCorrect ? 'Correct! Well done!' : 'Not quite right, but keep learning!',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'AI Confidence: $confidenceText',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (briefTip != null && briefTip.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      briefTip,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.orange,
        duration: const Duration(milliseconds: 3000),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _getConfidenceText(double confidenceScore) {
    if (confidenceScore >= 0.9) return 'Very High (${(confidenceScore * 100).toInt()}%)';
    if (confidenceScore >= 0.7) return 'High (${(confidenceScore * 100).toInt()}%)';
    if (confidenceScore >= 0.5) return 'Medium (${(confidenceScore * 100).toInt()}%)';
    return 'Low (${(confidenceScore * 100).toInt()}%)';
  }

  void _showDetailedFeedback() {
    if (_lastAnswerResult == null) return;
    
    final result = _lastAnswerResult!;
    final provider = context.read<FlashcardProvider>();
    final currentCard = provider.currentCard;
    
    if (currentCard == null) return;
    
    // Parse the enhanced feedback
    final feedbackContent = FeedbackContent.fromFeedback(result.feedback);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.correct ? Icons.check_circle : Icons.cancel,
              color: result.correct ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(result.correct ? 'Correct Answer!' : 'Answer Review'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentCard.word,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // User's Answer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Answer:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userAnswer,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Correct Answer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Correct Answer:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentCard.definition,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // AI Analysis
              Container(
                width: double.infinity,
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
                        Icon(
                          Icons.psychology,
                          color: Colors.purple.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'AI Analysis',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Confidence Score: ${_getConfidenceText(result.confidenceScore)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Result: ${result.correct ? "Correct" : "Incorrect"}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              // Enhanced Feedback Section
              if (feedbackContent.reasoning.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.feedback,
                            color: Colors.indigo.shade700,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'AI Feedback',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feedbackContent.reasoning,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Learning Tip Section
              if (feedbackContent.learningTip != null && feedbackContent.learningTip!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            'Learning Tip',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feedbackContent.learningTip!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Encouragement Section
              if (feedbackContent.encouragement != null && feedbackContent.encouragement!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.pink.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🌟', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            'Encouragement',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.pink.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feedbackContent.encouragement!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
  }

  Future<void> _createQuickSession(FlashcardProvider provider, String sessionName, int maxCards) async {
    // Reset UI state for new session
    _resetForNewSession();
    
    final request = CreateSessionRequest(
      sessionName: sessionName,
      sessionType: 'daily_review',
      studyMode: 'practice',
      maxCards: maxCards,
      includeReviewed: false,
      includeFavorites: false,
      smartSelection: true,
    );

    final response = await provider.createSession(request);
    
    if (response == null || !response.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.sessionError ?? 'Failed to create session'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    // Navigation is handled automatically by the main screen
  }

  void _showSessionComplete(FlashcardProvider provider, FlashcardAnswerResult result) {
    // Navigate to the session completion screen instead of showing a dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionCompletionScreen(
          sessionStats: result.sessionStats,
          sessionName: provider.currentSession?.sessionName ?? 'Study Session',
            onStartNewSession: () {
              // Navigate to flashcard home screen instead of just popping
              Navigator.pushReplacementNamed(context, '/flashcards');
              provider.endSession();
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted && context.mounted) {
                  _createQuickSession(provider, 'Quick Practice Session', 3);
                }
              });
            },
          onFinish: () {
            Navigator.pop(context); // Go back to flashcard home
            provider.endSession();
          },
        ),
      ),
    );
  }

  Widget _buildNoSession() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Active Session',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Create a session to start studying'),
        ],
      ),
    );
  }

}


// Session completion screen with detailed stats and options
class SessionCompletionScreen extends StatelessWidget {
  final SessionStats sessionStats;
  final String sessionName;
  final VoidCallback onStartNewSession;
  final VoidCallback onFinish;

  const SessionCompletionScreen({
    super.key,
    required this.sessionStats,
    required this.sessionName,
    required this.onStartNewSession,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGoodPerformance = sessionStats.accuracyPercentage >= 70;
    final accentColor = isGoodPerformance ? Colors.green : Colors.orange;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Complete'),
        backgroundColor: theme.colorScheme.inversePrimary,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Celebration header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withOpacity(0.1),
                    accentColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accentColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // Celebration icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isGoodPerformance ? Icons.celebration : Icons.check_circle,
                      size: 48,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    'Session Complete!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Session name
                  Text(
                    sessionName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Performance message
                  Text(
                    isGoodPerformance
                        ? 'Excellent work! You\'ve completed this session with great results.'
                        : 'Good job! You\'ve completed this session. Keep practicing to improve!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Detailed stats
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
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
                        Icons.analytics,
                        color: accentColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Session Statistics',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Stats grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Correct',
                          sessionStats.correctAnswers.toString(),
                          Colors.green,
                          Icons.check_circle,
                          theme,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Incorrect',
                          sessionStats.incorrectAnswers.toString(),
                          Colors.red,
                          Icons.cancel,
                          theme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Accuracy',
                          '${sessionStats.accuracyPercentage.toStringAsFixed(1)}%',
                          accentColor,
                          Icons.trending_up,
                          theme,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Total Cards',
                          (sessionStats.correctAnswers + sessionStats.incorrectAnswers).toString(),
                          Colors.blue,
                          Icons.style,
                          theme,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Progress tip
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keep Learning!',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your progress has been saved. Regular practice will help you master these vocabulary words!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Action buttons
            Column(
              children: [
                // Start New Session button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onStartNewSession,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start New Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Finish button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onFinish,
                    icon: const Icon(Icons.home),
                    label: const Text('Back to Home'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Stats screen is now imported from flashcard_stats_screen.dart
