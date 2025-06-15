import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main(){
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