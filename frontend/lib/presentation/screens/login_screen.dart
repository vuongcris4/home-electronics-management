// lib/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../widgets/login_form.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 40),
                const Text('Log in',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF13304A),
                        fontSize: 38.82,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.19)),

                const SizedBox(height: 12),

                const Text('Hi! Welcome',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFFC4C4C4),
                        fontSize: 22,
                        fontFamily: 'Poppins',
                        letterSpacing: 0.11)),

                const SizedBox(height: 60), 

                // FORM ĐĂNG NHẬP
                const LoginForm(),

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

              ],
            ),
          ),
        ),
      ),
    );
  }
}