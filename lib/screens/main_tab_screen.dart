import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'home_screen.dart';
import 'social_tab_screen.dart';
import 'more_tab_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    print('🏠 MainTabScreen initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Create screens list directly in build method
        final screens = [
          const HomeScreen(),
          const SocialTabScreen(),
          const MoreTabScreen(),
        ];

        print('🏠 MainTabScreen: screens.length = ${screens.length}');

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex.clamp(0, screens.length - 1),
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex.clamp(0, screens.length - 1),
            onTap: (index) {
              print('🏠 Tab tapped: $index, screens.length: ${screens.length}');
              print('🏠 Valid range: 0 to ${screens.length - 1}');
              setState(() {
                _currentIndex = index.clamp(0, screens.length - 1);
              });
              print('🏠 New currentIndex: $_currentIndex');
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF3498DB),
            unselectedItemColor: const Color(0xFF7F8C8D),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Social',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz),
                activeIcon: Icon(Icons.more_horiz),
                label: 'More',
              ),
            ],
          ),
        );
      },
    );
  }
}
