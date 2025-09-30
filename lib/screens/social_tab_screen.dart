import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'create_post_screen.dart';
import 'news_feed_screen.dart';

class SocialTabScreen extends StatefulWidget {
  const SocialTabScreen({super.key});

  @override
  State<SocialTabScreen> createState() => _SocialTabScreenState();
}

class _SocialTabScreenState extends State<SocialTabScreen> {
  int _refreshKey = 0;
  bool _shouldRefreshFeed = false;

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
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreatePostScreen(),
                ),
              );
              // If a post was created successfully, refresh the news feed
              if (result == true) {
                print('🔄 SocialTabScreen: Post created successfully, refreshing feed...');
                // Trigger a refresh by changing the key to force NewsFeedScreen rebuild
                setState(() {
                  _refreshKey++;
                  _shouldRefreshFeed = true;
                });
                print('🔄 SocialTabScreen: Refresh key updated to $_refreshKey');
              }
            },
            backgroundColor: const Color(0xFF3498DB),
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
          body: NewsFeedScreen(
            key: ValueKey(_refreshKey),
            shouldRefresh: _shouldRefreshFeed,
            onRefreshComplete: () {
              setState(() {
                _shouldRefreshFeed = false;
              });
            },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
        backgroundColor: const Color(0xFF3498DB),
        child: const Icon(
          Icons.add,
          color: Colors.white,
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