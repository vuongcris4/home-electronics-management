import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.0771; // 7.71% từ Figma

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56), // Tăng chiều cao của AppBar
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: EdgeInsets.only(
                left: screenSize.width * 0.0615), // 6.15% từ Figma
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF14304A),
                size: 24, // Tăng kích thước icon
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              SizedBox(
                  height: screenSize.height *
                      0.0821), // 82.1px từ Figma (678.75 - 596.65)
              const Text(
                'Create Account',
                style: TextStyle(
                  color: const Color(0xFF13304A),
                  fontSize: 28,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12), // Điều chỉnh khoảng cách
              const Text(
                'Fill your information below or register\nwith your social account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12, // Tăng font size
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFC4C4C4),
                  letterSpacing: 0.06, // Điều chỉnh letter spacing
                  height: 1.5,
                ),
              ),
              SizedBox(height: screenSize.height * 0.0654), // 65.4px từ Figma
              _buildInputField(label: 'Name', hintText: 'Your Name'),
              const SizedBox(height: 24), // Tăng khoảng cách giữa các input
              _buildInputField(
                  label: 'Email Address', hintText: 'Enter Your Email'),
              const SizedBox(height: 24),
              _buildInputField(
                label: 'Password',
                hintText: 'Enter Your Password',
                isPassword: true,
              ),
              const SizedBox(height: 24),
              _buildInputField(label: 'Phone No.', hintText: '+1'),
              SizedBox(height: screenSize.height * 0.0493), // 49.3px từ Figma
              Container(
                width: screenSize.width * 0.84, // 84% từ Figma
                height: 56, // Tăng chiều cao button
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: const Color(0xFF2666DE),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2666DE).withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: MaterialButton(
                  onPressed: () {},
                  child: const Text(
                    'Create',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18, // Tăng font size
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.09, // Điều chỉnh letter spacing
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8), // Tăng padding
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14, // Tăng font size
              fontWeight: FontWeight.w600,
              color: Color(0xFF14304A),
              letterSpacing: 0.07, // Điều chỉnh letter spacing
            ),
          ),
        ),
        SizedBox(
          height: 48, // Tăng chiều cao input field
          child: TextFormField(
            obscureText: isPassword,
            style: const TextStyle(
              fontSize: 16, // Tăng font size
              color: Color(0xFF14304A),
              letterSpacing: 0.112, // Điều chỉnh letter spacing
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFFCFCFCF),
                fontSize: 16, // Tăng font size
                fontWeight: FontWeight.w500,
                letterSpacing: 0.112, // Điều chỉnh letter spacing
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: const BorderSide(
                  color: Color(0xFFCFCFCF),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: const BorderSide(
                  color: Color(0xFFCFCFCF),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: const BorderSide(
                  color: Color(0xFF2666DE),
                  width: 1,
                ),
              ),
              suffixIcon: isPassword
                  ? const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(
                        Icons.visibility_off_outlined,
                        color: Color(0xFFCFCFCF),
                        size: 20,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
