// lib/presentation/widgets/login_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    // Thêm kiểm tra `mounted` để đảm bảo widget vẫn còn trong cây widget
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().loginState == ViewState.Loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(label: 'Email Address', hint: 'Enter Your Email', controller: _emailController, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 30),
        _buildTextField(label: 'Password', hint: 'Enter Your Password', isPassword: true, controller: _passwordController),
        const SizedBox(height: 60),
        ElevatedButton(
          onPressed: isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2666DE),
            padding: const EdgeInsets.symmetric(vertical: 19),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            elevation: 5,
          ),
          child: isLoading
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : const Text('Log In', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w600, letterSpacing: 0.14)),
        ),
      ],
    );
  }

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
        Text(label, style: const TextStyle(color: Color(0xFF13304A), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.bold, letterSpacing: 0.06)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFC4C4C4), fontSize: 20, fontFamily: 'Inter', letterSpacing: 0.10),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFCFCFCF))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2666DE), width: 2)),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}