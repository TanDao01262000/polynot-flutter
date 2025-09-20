import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/user_login_screen.dart';
import 'screens/user_registration_screen.dart';
import 'services/partner_service.dart';
import 'providers/vocabulary_provider.dart';
import 'providers/user_provider.dart';
import 'providers/flashcard_provider.dart';
import 'providers/tts_provider.dart';
import 'screens/vocabulary_list_screen.dart';
import 'screens/flashcard_screens.dart';
import 'screens/vocabulary_tts_demo_screen.dart';

void main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Check API health on startup (non-blocking)
  try {
    await PartnerService.checkHealth();
    print('Chat API is healthy and ready');
  } catch (e) {
    print('Warning: Chat API health check failed: $e');
    print('The app will continue to work, but chat features may not be available.');
    // Continue with app startup even if API is down
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VocabularyProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FlashcardProvider()),
        ChangeNotifierProvider(create: (_) => TTSProvider()),
      ],
      child: MaterialApp(
        title: "Polynot",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const HomeScreen(),
        routes: {
          '/login': (context) => const UserLoginScreen(),
          '/register': (context) => const UserRegistrationScreen(),
          '/vocabulary-list': (context) => const VocabularyListScreen(),
          '/flashcards': (context) => const FlashcardMainScreen(),
          '/tts-demo': (context) => const VocabularyTTSDemoScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}