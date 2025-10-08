import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'create_post_screen.dart';
import 'personalized_feed_screen.dart';
import 'public_feed_screen.dart';
import 'study_together_screen.dart';
import 'user_discovery_screen.dart';

class SocialTabScreen extends StatefulWidget {
  const SocialTabScreen({super.key});

  @override
  State<SocialTabScreen> createState() => _SocialTabScreenState();
}

class _SocialTabScreenState extends State<SocialTabScreen> with TickerProviderStateMixin {
  int _refreshKey = 0;
  bool _shouldRefreshFeed = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.isLoggedIn) {
          return _buildLoginPrompt(context);
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: const Text(
              'Social',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Color(0xFF5D6D7E)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserDiscoveryScreen(),
                    ),
                  );
                },
                tooltip: 'Discover Users',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF3498DB),
              labelColor: const Color(0xFF3498DB),
              unselectedLabelColor: const Color(0xFF7F8C8D),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.person, size: 20),
                  text: 'Personalized',
                ),
                Tab(
                  icon: Icon(Icons.public, size: 20),
                  text: 'Public',
                ),
                Tab(
                  icon: Icon(Icons.school, size: 20),
                  text: 'Study Together',
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreatePostScreen(),
                ),
              );
              // If a post was created successfully, refresh both feeds
              if (result == true) {
                print('🔄 SocialTabScreen: Post created successfully, refreshing feeds...');
                // Trigger a refresh by changing the key to force feed screens rebuild
                setState(() {
                  _refreshKey++;
                  _shouldRefreshFeed = true;
                });
                print('🔄 SocialTabScreen: Refresh key updated to $_refreshKey');
              }
            },
            backgroundColor: const Color(0xFF3498DB),
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              'Create Post',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Personalized Feed Tab
              PersonalizedFeedScreen(
                key: ValueKey('personalized_$_refreshKey'),
                shouldRefresh: _shouldRefreshFeed,
                onRefreshComplete: () {
                  setState(() {
                    _shouldRefreshFeed = false;
                  });
                },
              ),
              // Public Feed Tab
              PublicFeedScreen(
                key: ValueKey('public_$_refreshKey'),
                shouldRefresh: _shouldRefreshFeed,
                onRefreshComplete: () {
                  setState(() {
                    _shouldRefreshFeed = false;
                  });
                },
              ),
              // Study Together Tab
              StudyTogetherScreen(
                key: ValueKey('study_together_$_refreshKey'),
                shouldRefresh: _shouldRefreshFeed,
                onRefreshComplete: () {
                  setState(() {
                    _shouldRefreshFeed = false;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildLoginPrompt(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Social',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
        backgroundColor: const Color(0xFF3498DB),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.add),
        label: const Text(
          'Create Post',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.people,
                  size: 64,
                  color: Color(0xFF3498DB),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Join the Community!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Login to connect with your learning community and share your progress.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7F8C8D),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Login to Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}