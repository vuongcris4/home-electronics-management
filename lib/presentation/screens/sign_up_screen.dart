// lib/presentation/screens/sign_up_screen.dart
import 'package:flutter/material.dart';
import '../widgets/sign_up_form.dart'; // Import widget mới

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.0771;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: screenSize.width * 0.0615),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: Color(0xFF14304A), size: 24),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              SizedBox(height: screenSize.height * 0.0821),
              const Text('Create Account',
                  style: TextStyle(
                      color: Color(0xFF13304A),
                      fontSize: 28,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.14),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const Text(
                  'Fill your information below or register\nwith your social account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFC4C4C4),
                      letterSpacing: 0.06,
                      height: 1.5)),
              SizedBox(height: screenSize.height * 0.0654),
              
              // Sử dụng form widget đã tách
              const SignUpForm(), 
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}