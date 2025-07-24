import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/main_screen.dart';
import 'services/partner_service.dart';

void main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Check API health on startup
  try {
    await PartnerService.checkHealth();
    print('API is healthy and ready');
  } catch (e) {
    print('Warning: API health check failed: $e');
    // Continue with app startup even if API is down
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "AI Partner",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}