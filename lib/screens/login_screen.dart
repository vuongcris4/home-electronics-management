import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Services, Controllers, and Storage
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  // State variables
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm xử lý logic đăng nhập
  void _login() async {
    setState(() {
      _isLoading = true;
    });

    final response = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200 && mounted) {
      final data = jsonDecode(response.body);
      // Lưu trữ tokens một cách an toàn
      await _storage.write(key: 'access_token', value: data['access']);
      await _storage.write(key: 'refresh_token', value: data['refresh']);

      // --- THAY ĐỔI Ở ĐÂY ---
      // Chuyển hướng đến màn hình chính và xóa các route trước đó
      Navigator.pushReplacementNamed(context, '/home');
      // ---------------------

    } else {
      // Hiển thị lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email hoặc mật khẩu không đúng. Vui lòng thử lại."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(minHeight: screenHeight),
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 60),
                const Text(
                  'Log in',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF13304A),
                    fontSize: 38.82,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.19,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hi! Welcome',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFC4C4C4),
                    fontSize: 22,
                    fontFamily: 'Poppins',
                    letterSpacing: 0.11,
                  ),
                ),
                const SizedBox(height: 80),
                _buildTextField(
                  label: 'Email Address',
                  hint: 'Enter Your Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 30),
                _buildTextField(
                  label: 'Password',
                  hint: 'Enter Your Password',
                  isPassword: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2666DE),
                    padding: const EdgeInsets.symmetric(vertical: 19),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Log In',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.14,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2666DE),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 5,
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Don’t have an account ?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFC4C4C4),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Create an Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                const _OrDivider(),
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
                        width: 0.40,
                        color: const Color(0xFFF79AEE),
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/img/google_logo.png', // Hãy chắc chắn bạn có file này
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget helper để xây dựng các trường nhập liệu
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF13304A),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            letterSpacing: 0.06,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFC4C4C4),
              fontSize: 20,
              fontFamily: 'Inter',
              letterSpacing: 0.10,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFCFCFCF)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2666DE), width: 2),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

// Widget cho dải phân cách "Or Log in With"
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Color(0xFF0B6EFE), Color(0x00C4C4C4)],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or Log in With',
            style: TextStyle(
              color: Color(0xFF555151),
              fontSize: 12,
              fontFamily: 'Outfit',
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF0B6EFE), Color(0x00C4C4C4)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}