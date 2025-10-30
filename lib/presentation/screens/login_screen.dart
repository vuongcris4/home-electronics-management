// lib/presentation/screens/login_screen.dart

// Import thư viện Material của Flutter để sử dụng các widget cơ bản
import 'package:flutter/material.dart';
// Import widget 'LoginForm' tùy chỉnh
import '../widgets/login_form.dart';
// Import widget 'OrDivider' tùy chỉnh
import '../widgets/or_divider.dart';

// Định nghĩa widget cho màn hình Login
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy chiều cao thực tế của màn hình
    final screenHeight = MediaQuery.of(context).size.height;

    // Scaffold là khung sườn cơ bản của màn hình
    return Scaffold(
      backgroundColor: Colors.white,
      // SafeArea đảm bảo nội dung không bị che bởi tai thỏ/thanh trạng thái
      body: SafeArea(
        // SingleChildScrollView cho phép nội dung cuộn khi bàn phím hiện lên
        child: SingleChildScrollView(
          child: Container(
            // Đặt ràng buộc chiều cao tối thiểu bằng chiều cao màn hình (để căn giữa)
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top,
            ),
            // Đệm 35 pixel trái/phải
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            // Column xếp các widget con theo chiều dọc
            child: Column(
              // Căn giữa các con theo chiều dọc
              mainAxisAlignment: MainAxisAlignment.center,
              // Kéo dãn các con theo chiều ngang
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Khoảng cách
                const SizedBox(height: 40),
                // Tiêu đề "Log in"
                const Text('Log in',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF13304A),
                        fontSize: 38.82,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.19)),
                // Khoảng cách
                const SizedBox(height: 12),
                // Tiêu đề phụ "Hi! Welcome"
                const Text('Hi! Welcome',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFFC4C4C4),
                        fontSize: 22,
                        fontFamily: 'Poppins',
                        letterSpacing: 0.11)),
                // Khoảng cách
                const SizedBox(height: 60), // Reduced from 80

                // Widget tùy chỉnh chứa 2 ô textfield và nút login
                const LoginForm(),

                // Khoảng cách
                const SizedBox(height: 20),
                // Nút "Don't have an account?"
                ElevatedButton(
                    onPressed: () {
                      // Điều hướng đến màn hình đăng ký
                      Navigator.pushNamed(context, '/signup');
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2666DE),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                        elevation: 5),
                    // Nội dung nút gồm 2 dòng text
                    child: const Column(mainAxisSize: MainAxisSize.min, children: [
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
                // Khoảng cách
                const SizedBox(height: 40), // Reduced from 60
                // Widget tùy chỉnh hiển thị vạch kẻ "--- OR ---"
                const OrDivider(),
                // Khoảng cách
                const SizedBox(height: 30),
                // Căn giữa nút Google
                Align(
                    alignment: Alignment.center,
                    // Nút đăng nhập Google
                    child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                            color: const Color(0xFFEBE9EB),
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: 0.40, color: const Color(0xFFF79AEE))),
                        // Hiển thị logo Google
                        child: Center(
                            child: Image.asset('assets/img/google_logo.png',
                                width: 30, height: 30)))),
                // Khoảng cách
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}