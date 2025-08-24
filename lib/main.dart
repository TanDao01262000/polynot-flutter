import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/partner_service.dart';
import 'providers/vocabulary_provider.dart';
import 'providers/user_provider.dart';

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
      ],
      child: MaterialApp(
        title: "Polynot",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}