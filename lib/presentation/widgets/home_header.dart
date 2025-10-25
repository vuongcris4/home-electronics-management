// lib/presentation/widgets/home_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../injection_container.dart'; // Import GetIt

const Color kPrimaryColor = Color(0xFF2666DE);
const Color kTextColorPrimary = Color(0xFF07123C);
const Color kTextColorSecondary = Color(0xFF6F7EA8);

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  Future<void> _logout(BuildContext context) async {
    // Lấy instance của storage
    final storage = getIt<FlutterSecureStorage>();
    
    // Xóa tất cả các token đã lưu
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');

    // Điều hướng về màn hình login và xóa hết các màn hình cũ
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'October 21, 2025',
                style: TextStyle(color: kTextColorSecondary, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'Smart home',
                style: TextStyle(
                  color: kTextColorPrimary,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Nút Logout/Thoát
          GestureDetector(
            onTap: () => _logout(context), // <-- THAY ĐỔI Ở ĐÂY
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/exit.png',
                  width: 22,
                  height: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}