// lib/presentation/widgets/home_header.dart
import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF2666DE);
const Color kTextColorPrimary = Color(0xFF07123C);
const Color kTextColorSecondary = Color(0xFF6F7EA8);

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

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
                'October 21, 2025', // Bạn có thể thay bằng dữ liệu động
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
            onTap: () {
              // TODO: Xử lý logic đăng xuất
              // Ví dụ: Xóa token và điều hướng về màn hình login
              // Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
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