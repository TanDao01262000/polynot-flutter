import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard_models.dart';
import '../providers/flashcard_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/flashcard_widgets.dart';

// Main flashcard screen with navigation
class FlashcardMainScreen extends StatefulWidget {
  const FlashcardMainScreen({super.key});

  @override
  State<FlashcardMainScreen> createState() => _FlashcardMainScreenState();
}

class _FlashcardMainScreenState extends State<FlashcardMainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, FlashcardProvider>(
      builder: (context, userProvider, flashcardProvider, child) {
        // Auto-navigate to study screen when session is created
        if (flashcardProvider.isSessionActive && _selectedIndex != 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _selectedIndex = 1;
            });
          });
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
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
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
      
      if (userProvider.isLoggedIn && userProvider.currentUser?.id != null) {
        flashcardProvider.initializeWithUser(userProvider.currentUser!.id);
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
                      'Start with a quick 3-card practice session',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _createQuickSession(provider);
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Quick Practice'),
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
              
              // Custom Session Section
              Container(
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
                          color: Colors.grey[600],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Custom Session',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Create a personalized study session with your preferences',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showCustomSessionDialog(provider);
                        },
                        icon: const Icon(Icons.tune),
                        label: const Text('Create Custom Session'),
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
              ),
              
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
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: session.isActive ? Colors.green.shade50 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: session.isActive ? Colors.green.shade200 : Colors.grey.shade200,
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
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Active',
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

  Future<void> _createQuickSession(FlashcardProvider provider) async {
    final request = CreateSessionRequest(
      sessionName: 'Quick Practice Session',
      sessionType: 'daily_review',
      studyMode: 'practice',
      maxCards: 3,
      includeReviewed: false,
      includeFavorites: false,
      difficultyFilter: [],
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

  void _showCustomSessionDialog(FlashcardProvider provider) {
    showDialog(
      context: context,
      builder: (context) => CustomSessionDialog(
        provider: provider,
        onSessionCreated: () {
          Navigator.pop(context);
        },
      ),
    );
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
                    onTap: () {
                      Navigator.pop(context);
                      if (session.isActive) {
                        // For now, just show a message - resume functionality would need to be implemented
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Resume functionality coming soon'),
                            backgroundColor: Colors.orange,
                          ),
                        );
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
      _startTime = DateTime.now();
    });
    
    // Auto-focus on answer input for next card
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _answerFocusNode.requestFocus();
    });
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

        // Check if we have a current card
        if (provider.currentCard == null) {
          return _buildSessionComplete();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(provider.currentSession?.sessionName ?? 'Study'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                    isLoading: _isSubmittingAnswer,
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

                // Simple Next Card Button (temporary replacement for difficulty rating)
                const SizedBox(height: 16),
                Visibility(
                  visible: _isFlipped && _lastAnswerResult != null && !_lastAnswerResult!.sessionComplete,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmittingAnswer ? null : () => _proceedToNextCard(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmittingAnswer
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Next Card',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
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

    setState(() {
      _isSubmittingAnswer = true;
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
        });
        
        // Show immediate feedback
        _showFeedback(result.correct);
        
        // Check if session is complete
        if (result.sessionComplete) {
          print('🎯 SESSION COMPLETE - showing completion dialog');
          _showSessionComplete(provider, result);
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

    setState(() {
      _isSubmittingAnswer = true;
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
      _isSubmittingAnswer = false;
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
              Navigator.pop(context); // Go back to flashcard home
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              isCorrect ? 'Correct! Well done!' : 'Not quite right, but keep learning!',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.orange,
        duration: const Duration(milliseconds: 1500),
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

  void _showSessionComplete(FlashcardProvider provider, FlashcardAnswerResult result) {
    // Preserve session stats before showing dialog (since endSession() will clear them)
    final sessionStats = provider.sessionStats;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.celebration,
              color: (sessionStats?.accuracyPercentage ?? 0) >= 70 ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            const Text('Session Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (sessionStats?.accuracyPercentage ?? 0) >= 70
                  ? 'Excellent work! You\'ve completed this session with great results.'
                  : 'Good job! You\'ve completed this session. Keep practicing to improve!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (sessionStats != null)
              SessionStatsDisplay(
                stats: sessionStats,
                accentColor: sessionStats.accuracyPercentage >= 70 
                    ? Colors.green 
                    : Colors.orange,
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.blue.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your progress has been saved. Keep studying to improve your vocabulary!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to flashcard home
              provider.endSession();
            },
            child: const Text('Finish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to flashcard home
              provider.endSession();
              // Navigate to create new session
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted && context.mounted) {
                  Navigator.pushNamed(context, '/flashcards/create-session');
                }
              });
            },
            child: const Text('Start New Session'),
          ),
        ],
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

  Widget _buildSessionComplete() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 64, color: Colors.green),
          SizedBox(height: 16),
          Text(
            'Session Complete!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Great job! You\'ve finished this session.'),
        ],
      ),
    );
  }
}

// Custom session creation dialog
class CustomSessionDialog extends StatefulWidget {
  final FlashcardProvider provider;
  final VoidCallback onSessionCreated;

  const CustomSessionDialog({
    super.key,
    required this.provider,
    required this.onSessionCreated,
  });

  @override
  State<CustomSessionDialog> createState() => _CustomSessionDialogState();
}

class _CustomSessionDialogState extends State<CustomSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _sessionNameController = TextEditingController();
  
  String _selectedStudyMode = 'practice';
  String _selectedSessionType = 'daily_review';
  int _maxCards = 20;
  bool _smartSelection = true;
  bool _includeReviewed = false;
  bool _includeFavorites = false;

  @override
  void initState() {
    super.initState();
    _sessionNameController.text = 'Custom Study Session';
  }

  @override
  void dispose() {
    _sessionNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Custom Session'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session Name
                TextFormField(
                  controller: _sessionNameController,
                  decoration: const InputDecoration(
                    labelText: 'Session Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a session name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Study Mode
                Text(
                  'Study Mode',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedStudyMode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: widget.provider.studyModes.map((mode) {
                    return DropdownMenuItem(
                      value: mode.value,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(mode.name),
                          Text(
                            mode.description,
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
                      setState(() {
                        _selectedStudyMode = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Session Type
                Text(
                  'Session Type',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedSessionType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: widget.provider.sessionTypes.map((type) {
                    return DropdownMenuItem(
                      value: type.value,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(type.name),
                          Text(
                            type.description,
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
                      setState(() {
                        _selectedSessionType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Max Cards
                Text(
                  'Number of Cards',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _maxCards.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 9,
                  label: _maxCards.toString(),
                  onChanged: (value) {
                    setState(() {
                      _maxCards = value.round();
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Options
                Text(
                  'Options',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Smart Selection'),
                  subtitle: const Text('AI-powered card selection'),
                  value: _smartSelection,
                  onChanged: (value) {
                    setState(() {
                      _smartSelection = value ?? true;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  title: const Text('Include Reviewed'),
                  subtitle: const Text('Include previously reviewed cards'),
                  value: _includeReviewed,
                  onChanged: (value) {
                    setState(() {
                      _includeReviewed = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  title: const Text('Include Favorites'),
                  subtitle: const Text('Include favorite vocabulary'),
                  value: _includeFavorites,
                  onChanged: (value) {
                    setState(() {
                      _includeFavorites = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: widget.provider.isLoadingSession ? null : _createSession,
          child: widget.provider.isLoadingSession
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Session'),
        ),
      ],
    );
  }

  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate()) return;

    final request = CreateSessionRequest(
      sessionName: _sessionNameController.text.trim(),
      sessionType: _selectedSessionType,
      studyMode: _selectedStudyMode,
      maxCards: _maxCards,
      includeReviewed: _includeReviewed,
      includeFavorites: _includeFavorites,
      difficultyFilter: [],
      smartSelection: _smartSelection,
    );

    final response = await widget.provider.createSession(request);
    
    if (response != null && response.success) {
      widget.onSessionCreated();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.provider.sessionError ?? 'Failed to create session'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Simple stats screen
class FlashcardStatsScreen extends StatelessWidget {
  const FlashcardStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Stats Screen - Coming Soon'),
    );
  }
}
