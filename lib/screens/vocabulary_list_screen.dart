import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vocabulary_category.dart';
import '../models/vocabulary_item.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/user_provider.dart';
import '../providers/tts_provider.dart';
import '../widgets/vocabulary_interaction_card.dart';
import '../utils/app_utils.dart';
import '../services/activity_service.dart';
import 'vocabulary_generation_screen.dart';
import 'dart:async';

class VocabularyListScreen extends StatefulWidget {
  const VocabularyListScreen({super.key});

  @override
  State<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? _selectedTopic;
  String? _selectedLevel;
  bool _showFavoritesOnly = false;
  bool _showHidden = false;
  
  bool _hasInitialized = false;
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (_hasInitialized) return;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final vocabProvider = Provider.of<VocabularyProvider>(context, listen: false);
    final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
    
    if (userProvider.currentUser != null && userProvider.sessionToken != null) {
      print('🔐 VocabularyListScreen: Setting session token WITH UserProvider for auto-refresh');
      vocabProvider.setSessionToken(
        userProvider.sessionToken!,
        userProvider: userProvider,  // ← Pass UserProvider for auto token refresh!
      );
      ttsProvider.setCurrentUserId(userProvider.sessionToken!);
      await vocabProvider.getVocabularyLists();
    } else {
      print('🔐 VocabularyListScreen: No session token available - user: ${userProvider.currentUser != null}, token: ${userProvider.sessionToken != null}');
    }
    
    _loadVocabularyList();
    _hasInitialized = true;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<VocabularyProvider>(context, listen: false);
      if (provider.hasMore && !provider.isLoadingList) {
        _loadMoreVocabulary();
      }
    }
  }

  Future<void> _loadVocabularyList() async {
    print('📚 === LOAD VOCABULARY LIST START ===');
    print('📚 Method called');
    
    final provider = Provider.of<VocabularyProvider>(context, listen: false);
    print('📚 Provider obtained');
    
    final searchTerm = _searchController.text.trim();
    print('📚 Search term: "$searchTerm"');
    print('📚 Search term length: ${searchTerm.length}');
    print('📚 Search term is empty: ${searchTerm.isEmpty}');
    
    print('📚 Current filters:');
    print('📚   - topic: $_selectedTopic');
    print('📚   - level: $_selectedLevel');
    print('📚   - favorites: $_showFavoritesOnly');
    print('📚   - hidden: $_showHidden');
    
    final request = VocabularyListRequest(
      page: 1,
      limit: 20,
      showFavoritesOnly: _showFavoritesOnly,
      showHidden: _showHidden,
      topicName: _selectedTopic,
      level: _selectedLevel,
      searchTerm: searchTerm.isEmpty ? null : searchTerm,
    );
    
    print('📚 Request created');
    print('📚 Request JSON: ${request.toJson()}');
    
    try {
      print('📚 Calling provider.getVocabularyList...');
      await provider.getVocabularyList(request);
      print('📚 Provider.getVocabularyList completed successfully');
      print('📚 Current items count: ${provider.vocabularyListItems.length}');
    } catch (e) {
      print('📚 ❌ ERROR in _loadVocabularyList: $e');
      print('📚 Error type: ${e.runtimeType}');
      print('📚 Error stack trace: ${StackTrace.current}');
      if (mounted) {
        print('📚 Widget is mounted, showing error snackbar');
        AppUtils.showErrorSnackBar(
          context,
          'Failed to load vocabulary: ${e.toString()}',
          onRetry: _loadVocabularyList,
        );
      } else {
        print('📚 Widget is NOT mounted, skipping error snackbar');
      }
    }
    print('📚 === LOAD VOCABULARY LIST END ===');
  }

  Future<void> _loadMoreVocabulary() async {
    final provider = Provider.of<VocabularyProvider>(context, listen: false);
    final request = VocabularyListRequest(
      page: 1,
      limit: 20,
      showFavoritesOnly: _showFavoritesOnly,
      showHidden: _showHidden,
      topicName: _selectedTopic,
      level: _selectedLevel,
      searchTerm: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
    );
    
    await provider.loadMoreVocabulary(request);
  }

  void _onSearchChanged(String value) {
    print('🔍 === SEARCH DEBUG START ===');
    print('🔍 Search changed called with value: "$value"');
    print('🔍 Search controller text: "${_searchController.text}"');
    print('🔍 Search controller text length: ${_searchController.text.length}');
    print('🔍 Widget mounted: $mounted');
    
    // Cancel previous timer
    if (_searchDebounceTimer != null) {
      print('🔍 Cancelling previous timer');
      _searchDebounceTimer?.cancel();
    } else {
      print('🔍 No previous timer to cancel');
    }
    
    // Set new timer for debounced search
    print('🔍 Setting new timer for 500ms');
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      print('🔍 === TIMER EXPIRED ===');
      print('🔍 Timer expired, checking if widget is mounted');
      print('🔍 Widget mounted: $mounted');
      if (mounted) {
        print('🔍 Widget is mounted, calling _loadVocabularyList');
        _loadVocabularyList();
      } else {
        print('🔍 Widget is NOT mounted, skipping _loadVocabularyList');
      }
    });
    print('🔍 Timer set successfully');
    print('🔍 === SEARCH DEBUG END ===');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Text(userProvider.currentUser != null 
              ? 'My Vocabulary' 
              : 'Vocabulary List');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          // IconButton(
          //   icon: const Icon(Icons.bookmark),
          //   onPressed: () => _showPersonalLists(context),
          // ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search vocabulary...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchDebounceTimer?.cancel();
                          _loadVocabularyList();
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          
          // Active filters display
          if (_hasActiveFilters()) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_selectedTopic != null)
                    _buildFilterChip('Topic: $_selectedTopic', () {
                      setState(() => _selectedTopic = null);
                      _loadVocabularyList();
                    }),
                  if (_selectedLevel != null)
                    _buildFilterChip('Level: $_selectedLevel', () {
                      setState(() => _selectedLevel = null);
                      _loadVocabularyList();
                    }),
                  if (_showFavoritesOnly)
                    _buildFilterChip('Favorites only', () {
                      setState(() => _showFavoritesOnly = false);
                      _loadVocabularyList();
                    }),
                  if (_showHidden)
                    _buildFilterChip('Show hidden', () {
                      setState(() => _showHidden = false);
                      _loadVocabularyList();
                    }),
                ],
              ),
            ),
          ],

          // Search results indicator
          if (_searchController.text.trim().isNotEmpty) ...[
            Consumer<VocabularyProvider>(
              builder: (context, provider, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Search results for "${_searchController.text.trim()}" (${provider.vocabularyListItems.length} items)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      if (provider.isLoadingList)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],

          // Vocabulary list
          Expanded(
            child: Consumer<VocabularyProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingList && provider.vocabularyListItems.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading vocabulary...'),
                      ],
                    ),
                  );
                }

                if (provider.error != null && provider.vocabularyListItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadVocabularyList,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.vocabularyListItems.isEmpty) {
                  return Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.book_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              userProvider.currentUser != null 
                                ? 'No vocabulary saved yet'
                                : 'No vocabulary found',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              userProvider.currentUser != null
                                ? 'Start by generating and saving some vocabulary!'
                                : 'Try adjusting your search or filters',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                            if (userProvider.currentUser != null) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const VocabularyGenerationScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Generate Vocabulary'),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadVocabularyList,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 80, // Add bottom padding to prevent FAB overlap
                    ),
                    itemCount: provider.vocabularyListItems.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.vocabularyListItems.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final item = provider.vocabularyListItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: VocabularyInteractionCard(
                          item: item,
                          onFavorite: () => provider.toggleFavorite(item.id),
                          onHide: () => item.isHidden 
                              ? provider.unhideVocabulary(item.id)
                              : provider.hideVocabulary(item.id),
                          onReview: () async {
                            // Get the current item state from the provider
                            final currentItem = provider.vocabularyListItems.firstWhere(
                              (i) => i.id == item.id,
                              orElse: () => item,
                            );
                            if (currentItem.lastReviewed != null) {
                              provider.unmarkAsReviewed(item.id);
                            } else {
                              provider.markAsReviewed(item.id);
                              
                              // Record vocabulary study activity for streak tracking
                              final userProvider = Provider.of<UserProvider>(context, listen: false);
                              if (userProvider.isLoggedIn && userProvider.currentUser != null) {
                                await ActivityService.recordVocabularyStudy(
                                  userId: userProvider.currentUser!.id,
                                  wordsStudied: 1,
                                  vocabularyList: item.category,
                                );
                              }
                            }
                          },
                          onAddNote: (note) => provider.addNote(item.id, note),
                          onRate: (rating) => provider.rateDifficulty(item.id, rating),
                          onAddToList: (listId) => provider.addToVocabularyList(listId, item.id),
                          personalLists: provider.personalLists,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.currentUser == null) {
            return const SizedBox.shrink();
          }
          
          // return FloatingActionButton.extended(
          //   onPressed: () => _showCreateListDialog(context),
          //   icon: const Icon(Icons.add),
          //   label: const Text('Create List'),
          // );
          return const SizedBox.shrink(); // Hide Create List button for now
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        onDeleted: onRemove,
        deleteIcon: const Icon(Icons.close, size: 18),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedTopic != null ||
           _selectedLevel != null ||
           _showFavoritesOnly ||
           _showHidden;
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        selectedTopic: _selectedTopic,
        selectedLevel: _selectedLevel,
        showFavoritesOnly: _showFavoritesOnly,
        showHidden: _showHidden,
        onApply: (topic, level, favorites, hidden) {
          print('🔍 Filter applied:');
          print('🔍   - showHidden: $hidden (was: $_showHidden)');
          print('🔍   - showFavoritesOnly: $favorites');
          print('🔍   - topic: $topic');
          print('🔍   - level: $level');
          
          setState(() {
            _selectedTopic = topic;
            _selectedLevel = level;
            _showFavoritesOnly = favorites;
            _showHidden = hidden;
          });
          _loadVocabularyList();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showPersonalLists(BuildContext context) {
    final provider = Provider.of<VocabularyProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to view personal lists')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PersonalListsBottomSheet(
        lists: provider.personalLists,
        onRefresh: () => provider.getVocabularyLists(),
      ),
    );
  }

  void _showCreateListDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Vocabulary List'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'List Name',
                hintText: 'Enter list name...',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                final provider = Provider.of<VocabularyProvider>(context, listen: false);
                await provider.createVocabularyList(
                  nameController.text.trim(),
                  descriptionController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final String? selectedTopic;
  final String? selectedLevel;
  final bool showFavoritesOnly;
  final bool showHidden;
  final Function(String?, String?, bool, bool) onApply;

  const _FilterBottomSheet({
    required this.selectedTopic,
    required this.selectedLevel,
    required this.showFavoritesOnly,
    required this.showHidden,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String? _topic;
  late String? _level;
  late bool _favoritesOnly;
  late bool _showHidden;

  final List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  @override
  void initState() {
    super.initState();
    _topic = widget.selectedTopic;
    _level = widget.selectedLevel;
    _favoritesOnly = widget.showFavoritesOnly;
    _showHidden = widget.showHidden;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filter Vocabulary',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          

          
          // Level dropdown
          DropdownButtonFormField<String>(
            value: _level,
            decoration: const InputDecoration(
              labelText: 'Level',
              border: OutlineInputBorder(),
            ),
            hint: const Text('Select level'),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All levels'),
              ),
              ..._levels.map((level) => DropdownMenuItem(
                value: level,
                child: Text(level),
              )),
            ],
            onChanged: (value) {
              setState(() => _level = value);
            },
          ),
          const SizedBox(height: 16),
          
          // Checkboxes
          CheckboxListTile(
            title: const Text('Favorites only'),
            value: _favoritesOnly,
            onChanged: (value) {
              setState(() => _favoritesOnly = value ?? false);
            },
          ),
          CheckboxListTile(
            title: const Text('Include hidden'),
            value: _showHidden,
            onChanged: (value) {
              setState(() => _showHidden = value ?? false);
            },
          ),
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _topic = null;
                      _level = null;
                      _favoritesOnly = false;
                      _showHidden = false;
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_topic, _level, _favoritesOnly, _showHidden);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PersonalListsBottomSheet extends StatelessWidget {
  final List<VocabularyPersonalList> lists;
  final VoidCallback onRefresh;

  const _PersonalListsBottomSheet({
    required this.lists,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Personal Lists',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (lists.isEmpty) ...[
            const Center(
              child: Column(
                children: [
                  Icon(Icons.bookmark_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No personal lists yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  final list = lists[index];
                  return ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: Text(list.name),
                    subtitle: Text(list.description),
                    trailing: Text('${list.vocabCount} items'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to list detail screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PersonalListDetailScreen(list: list),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// New screen for viewing personal list contents
class PersonalListDetailScreen extends StatefulWidget {
  final VocabularyPersonalList list;

  const PersonalListDetailScreen({
    super.key,
    required this.list,
  });

  @override
  State<PersonalListDetailScreen> createState() => _PersonalListDetailScreenState();
}

class _PersonalListDetailScreenState extends State<PersonalListDetailScreen> {
  List<VocabularyItem> _listItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadListContents();
  }

  Future<void> _loadListContents() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final provider = Provider.of<VocabularyProvider>(context, listen: false);
      final items = await provider.getListContents(widget.list.id);
      
      setState(() {
        _listItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading list',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadListContents,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_listItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No vocabulary items yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add vocabulary items to this list to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back to Vocabulary'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _listItems.length,
      itemBuilder: (context, index) {
        final item = _listItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              item.word,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(item.definition),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                // TODO: Implement remove from list functionality
              },
            ),
          ),
        );
      },
    );
  }
}
