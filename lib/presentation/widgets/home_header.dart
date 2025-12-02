// lib/presentation/widgets/home_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../injection_container.dart';
import '../providers/auth_provider.dart';
import '../providers/home_provider.dart';

const Color kPrimaryColor = Color(0xFF2666DE);
const Color kTextColorPrimary = Color(0xFF07123C);
const Color kTextColorSecondary = Color(0xFF6F7EA8);

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    authProvider.clearUserData();
    await homeProvider.clearLocalData();

    final storage = getIt<FlutterSecureStorage>();
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===================== MODIFIED WIDGET =====================
              Text(
                DateFormat('MMMM d, yyyy').format(DateTime.now()),
                style: const TextStyle(color: kTextColorSecondary, fontSize: 14),
              ),
              // ==========================================================
              const SizedBox(height: 8),
              const Text(
                'Smart home',
                style: TextStyle(
                  color: kTextColorPrimary,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // ===================== MODIFIED WIDGET (LOGOUT BUTTON) =====================
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Image.asset('assets/icons/exit.png',),
              onPressed: () => _logout(context),
            ),
          ),
          // ========================================================================
        ],
      ),
    );
  }
}