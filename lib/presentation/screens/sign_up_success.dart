import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignUpSuccessScreen extends StatelessWidget {
  const SignUpSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 221),
                Center(
                  child: SizedBox(
                    width: 157.067,
                    height: 155.414,
                    child: SvgPicture.asset(
                      'assets/img/User_Check.svg', // Đảm bảo bạn có file svg này trong assets/images
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 86.586),
                const Center(
                  child: Text(
                    'Successfully!!!',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.28,
                      color: Color(0xFF2754A5),
                      height: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                    height:
                        86.59), 
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 31),
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2666DE),
                    borderRadius: BorderRadius.circular(32),
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
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}