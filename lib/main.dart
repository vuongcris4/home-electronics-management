import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/sign_up_success.dart';
import 'screens/home_screen.dart'; // <-- THÊM DÒNG NÀY

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2666DE),
          primary: const Color(0xFF2666DE),
        ),
        fontFamily: 'Inter',
        useMaterial3: false,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/signup-success': (context) => const SignUpSuccessScreen(),
        '/home': (context) => const SmartHomeScreen(), // <-- THÊM DÒNG NÀY
      },
    );
  }
}