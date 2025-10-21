// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/home_provider.dart';

import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/sign_up_screen.dart';
import 'presentation/screens/sign_up_success.dart';
import 'injection_container.dart' as di;

void main() async {
  // Khởi tạo dependency injection trước khi chạy app
  WidgetsFlutterBinding.ensureInitialized(); // Cần thiết
  await di.init();  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Cung cấp AuthProvider cho cây widget
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<HomeProvider>()), // <-- THÊM DÒNG NÀY
      ],
      child: MaterialApp(
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
          '/home': (context) => const SmartHomeScreen(),
        },
      ),
    );
  }
}