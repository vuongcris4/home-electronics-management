// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/navigation/navigation_service.dart'; // <-- IMPORT
import 'presentation/providers/home_provider.dart';

import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/sign_up_screen.dart';
import 'presentation/screens/sign_up_success.dart';
import 'presentation/screens/splash_screen.dart'; // <-- 1. IMPORT
import 'injection_container.dart' as di;

void main() async {
  // Khởi tạo dependency injection trước khi chạy app
  WidgetsFlutterBinding.ensureInitialized(); // Tạo hoặc lấy instance duy nhất của WidgetsFlutterBinding. Tạo một binding giữa Flutter engine (C++) và framework (Dart). Khởi tạo hệ thống widget, rendering, scheduler, services…; Cho phép bạn truy cập các API gốc (như plugin, SharedPreferences, MethodChannel, rootBundle…); Được dùng trước khi runApp(), trong main().

  await di.configureDependencies();  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Cung cấp AuthProvider cho cây widget
    return MultiProvider( // giúp bạn khai báo nhiều Provider cùng lúc.
      providers: [
        // Đây là provider cơ bản nhất, dùng để:
          // Tạo instance của class ChangeNotifier
          // Quản lý vòng đời (dispose tự động)
          // Cho phép context.watch, context.read, Consumer, v.v. trong UI.
          // đưa instance đó vào cây widget, giúp mọi widget con trong app có thể truy cập AuthProvider qua context.
        ChangeNotifierProvider(create: (_) => di.getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.getIt<HomeProvider>()), 
      ],
      child: MaterialApp(
        navigatorKey: di.getIt<NavigationService>().navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2666DE),
            primary: const Color(0xFF2666DE),
          ),
          fontFamily: 'Inter',
          useMaterial3: false,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(), 
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/signup-success': (context) => const SignUpSuccessScreen(),
          '/home': (context) => const SmartHomeScreen(),
        },
      ),
    );
  }
}