// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/navigation/navigation_service.dart';
import 'domain/entities/device.dart';
import 'presentation/providers/home_provider.dart';

import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/add_device_screen.dart';
import 'presentation/screens/add_room_screen.dart'; // <-- 1. IMPORT
import 'presentation/screens/control_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/sign_up_screen.dart';
import 'presentation/screens/sign_up_success.dart';
import 'presentation/screens/splash_screen.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
          '/add-device': (context) => const AddDeviceScreen(),
          '/add-room': (context) => const AddRoomScreen(), // <-- 2. ADD ROUTE
          '/control-device': (context) {
            // Lấy device object được truyền qua arguments
            final device =
                ModalRoute.of(context)!.settings.arguments as Device;
            return ControlScreen(device: device);
          },
        },
      ),
    );
  }
}