// lib/presentation/widgets/sign_up_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (!mounted) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu không khớp!")),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      password2: _confirmPasswordController.text,
      phoneNumber: _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/signup-success', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Đăng ký thất bại: ${authProvider.errorMessage}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLoading = context.watch<AuthProvider>().registerState == ViewState.Loading;

    return Column(
      children: [
        _buildInputField(label: 'Name', hintText: 'Your Name', controller: _nameController),
        const SizedBox(height: 24),
        _buildInputField(label: 'Email Address', hintText: 'Enter Your Email', controller: _emailController, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 24),
        _buildInputField(label: 'Password', hintText: 'Enter Your Password', isPassword: true, controller: _passwordController),
        const SizedBox(height: 24),
        _buildInputField(label: 'Confirm Password', hintText: 'Confirm Your Password', isPassword: true, controller: _confirmPasswordController),
        const SizedBox(height: 24),
        _buildInputField(label: 'Phone No.', hintText: '+84', controller: _phoneController, keyboardType: TextInputType.phone),
        SizedBox(height: screenSize.height * 0.0493),
        Container(
          width: screenSize.width * 0.84,
          height: 56,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(32), color: const Color(0xFF2666DE), boxShadow: [BoxShadow(color: const Color(0xFF2666DE).withOpacity(0.3), offset: const Offset(0, 4), blurRadius: 12, spreadRadius: 0)]),
          child: MaterialButton(
            onPressed: isLoading ? null : _signUp,
            child: isLoading
                ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                : const Text('Create', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.09)),
          ),
        ),
      ],
    );
  }

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
        Padding(padding: const EdgeInsets.only(left: 12, bottom: 8), child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF14304A), letterSpacing: 0.07))),
        SizedBox(
          height: 48,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isPassword && !_isPasswordVisible,
            style: const TextStyle(fontSize: 16, color: Color(0xFF14304A), letterSpacing: 0.112),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.112),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: const BorderSide(color: Color(0xFFCFCFCF), width: 1)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: const BorderSide(color: Color(0xFFCFCFCF), width: 1)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: const BorderSide(color: Color(0xFF2666DE), width: 1)),
              suffixIcon: isPassword
                  ? IconButton(
                      padding: const EdgeInsets.only(right: 20),
                      icon: Icon(_isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFFCFCFCF), size: 20),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}