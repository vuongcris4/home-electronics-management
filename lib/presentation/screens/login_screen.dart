// lib/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_form.dart'; // <-- Widget Form mới
import '../widgets/or_divider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // Widget này đảm bảo rằng nội dung bên trong nó sẽ không bị che khuất bởi tai thỏ (notch), thanh trạng thái, hoặc các góc bo tròn của màn hình điện thoại.
        child: SingleChildScrollView(
          // Nó bao bọc toàn bộ nội dung, cho phép người dùng cuộn màn hình nếu nội dung dài hơn chiều cao của thiết bị. Điều này rất quan trọng để tránh lỗi "overflow" (tràn pixel) khi bàn phím ảo hiện lên.
          child: Container(
            constraints: BoxConstraints(
                minHeight:
                    screenHeight), // thiết lập chiều cao tối thiểu bằng chiều cao màn hình.
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // căn giữa widget con trong column
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 60),
                const Text('Log in',  // Chữ Log in
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF13304A),
                        fontSize: 38.82,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.19)),
                const SizedBox(height: 12),
                const Text('Hi! Welcome', // Chữ Hi! Welcome
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFFC4C4C4),
                        fontSize: 22,
                        fontFamily: 'Poppins',
                        letterSpacing: 0.11)),
                const SizedBox(height: 80),

                const LoginForm(), // <-- Sử dụng widget form đã tách

                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2666DE),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                        elevation: 5),
                    child:
                        const Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('Don’t have an account ?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xFFC4C4C4),
                              fontSize: 12,
                              fontFamily: 'Poppins')),
                      SizedBox(height: 2),
                      Text('Create an Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold))
                    ])),
                const SizedBox(height: 60),
                const OrDivider(), // <-- Sử dụng widget đã tách
                const SizedBox(height: 30),
                Align(
                    alignment: Alignment.center,
                    child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                            color: const Color(0xFFEBE9EB),
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: 0.40, color: const Color(0xFFF79AEE))),
                        child: Center(
                            child: Image.asset('assets/img/google_logo.png',
                                width: 30, height: 30)))),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
