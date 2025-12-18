import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../injection_container.dart'; // Import service locator

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Lấy instance của FlutterSecureStorage từ GetIt
    final storage = getIt<FlutterSecureStorage>();
    
    // Đợi một chút để người dùng thấy màn hình splash (tùy chọn)
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Đọc access token
    final accessToken = await storage.read(key: 'access_token');

    // Kiểm tra mounted trước khi điều hướng
    if (!mounted) return;

    if (accessToken != null) {
      // Nếu có token, chuyển đến màn hình Home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Nếu không có token, chuyển đến màn hình Login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị một giao diện loading đơn giản
    return const Scaffold(
      backgroundColor: Color(0xFF2666DE), // Đồng bộ màu với app
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}