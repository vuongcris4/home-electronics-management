import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Import AuthService

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Services and Controllers
  final AuthService _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // Controller cho confirm password
  final _phoneController = TextEditingController();

  // State variables
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    // Dọn dẹp controllers khi widget bị hủy
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Hàm xử lý logic đăng ký
  void _signUp() async {
    // Kiểm tra xem mật khẩu có khớp không
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu không khớp!")),
      );
      return;
    }

    // Hiển thị loading indicator
    setState(() {
      _isLoading = true;
    });

    // Gọi API
    final response = await _authService.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _confirmPasswordController.text,
      _phoneController.text.trim(),
    );

    // Ẩn loading indicator
    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 201 && mounted) {
      // Đăng ký thành công, chuyển hướng đến trang success
      Navigator.pushNamedAndRemoveUntil(context, '/signup-success', (route) => false);
    } else {
      // Xử lý lỗi từ server và hiển thị cho người dùng
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      String errorMessage = "Đã có lỗi xảy ra. Vui lòng thử lại.";
      if (responseBody is Map<String, dynamic> && responseBody.isNotEmpty) {
          // Lấy thông báo lỗi đầu tiên từ phản hồi của API
          final firstError = responseBody.values.first;
          if(firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first.toString();
          } else {
            errorMessage = firstError.toString();
          }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thất bại: $errorMessage')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.0771;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: EdgeInsets.only(left: screenSize.width * 0.0615),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF14304A),
                size: 24,
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
              SizedBox(height: screenSize.height * 0.0821),
              const Text(
                'Create Account',
                style: TextStyle(
                  color: Color(0xFF13304A),
                  fontSize: 28,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Fill your information below or register\nwith your social account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFC4C4C4),
                  letterSpacing: 0.06,
                  height: 1.5,
                ),
              ),
              SizedBox(height: screenSize.height * 0.0654),
              _buildInputField(
                label: 'Name',
                hintText: 'Your Name',
                controller: _nameController,
              ),
              const SizedBox(height: 24),
              _buildInputField(
                label: 'Email Address',
                hintText: 'Enter Your Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              _buildInputField(
                label: 'Password',
                hintText: 'Enter Your Password',
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 24),
              _buildInputField(
                label: 'Confirm Password', // Trường mới
                hintText: 'Confirm Your Password',
                isPassword: true,
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 24),
              _buildInputField(
                label: 'Phone No.',
                hintText: '+84',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: screenSize.height * 0.0493),
              Container(
                width: screenSize.width * 0.84,
                height: 56,
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
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Create',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.09,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40), // Thêm khoảng đệm dưới cùng
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper để xây dựng các trường nhập liệu
  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF14304A),
              letterSpacing: 0.07,
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isPassword && !_isPasswordVisible,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF14304A),
              letterSpacing: 0.112,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFFCFCFCF),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.112,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: const BorderSide(color: Color(0xFFCFCFCF), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: const BorderSide(color: Color(0xFFCFCFCF), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: const BorderSide(color: Color(0xFF2666DE), width: 1),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      padding: const EdgeInsets.only(right: 20),
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: const Color(0xFFCFCFCF),
                        size: 20,
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
        ),
      ],
    );
  }
}