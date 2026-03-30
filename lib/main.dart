import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Device Info App',

      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        cardColor: Colors.white,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
      ),

      themeMode: ThemeMode.system, // 🔥 auto device theme

      home: const SplashScreen(),
    );
  }
}