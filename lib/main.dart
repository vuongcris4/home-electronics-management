import 'package:flutter/material.dart';
import 'screens/sign_up_screen.dart';
import 'screens/sign_up_success.dart';
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
      // Để chuyển qua lại giữa màn SignUp và SignUpSuccess, chỉ cần đổi
      // home: const SignUpScreen(), hoặc
      home: const SignUpSuccessScreen(),
      // home: const SignUpScreen(),
    );
  }
}