// lib/presentation/screens/alerts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../injection_container.dart';
import '../providers/auth_provider.dart';
import '../providers/home_provider.dart';

const Color kPrimaryColor = Color(0xFF2666DE);

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  // ===================== MODIFIED METHOD =====================
  /// Handles user logout by clearing all local data, tokens, and navigating to the login screen.
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
  // ===================== END OF MODIFIED METHOD =====================

  /// Widget to build each log/alert card.
  Widget _buildAlertCard(AlertLog alert) {
    final bool isWarning = alert.type == AlertType.warning;
    final Color cardColor = isWarning ? Colors.orange.shade50 : Colors.white;
    final Color iconColor = isWarning ? Colors.orange.shade800 : kPrimaryColor;
    final IconData iconData =
        isWarning ? Icons.warning_amber_rounded : Icons.info_outline;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.message,
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm:ss').format(alert.timestamp),
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentDate =
        DateFormat('MMMM d, yyyy').format(DateTime.now());

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentDate, // Dynamic date
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Smart home',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Image.asset('assets/icons/exit.png', ),
                    onPressed: () => _logout(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  const Text(
                    'Activity Log',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6F7EA8),
                    ),
                  ),
                  const SizedBox(width: 8), 
                  Image.asset(
                    'assets/icons/notific.png',
                    width: 24,
                    height: 24,
                  )
                ],
              ),
            ),
        ),
          const SizedBox(height: 20),
          // LIST OF LOGS AND ALERTS
          Expanded(
            child: Consumer<HomeProvider>(
              builder: (context, provider, child) {
                final alerts = provider.alerts;
                if (alerts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No activity recorded for today.',
                      style: TextStyle(color: Color(0xFF6F7EA8), fontSize: 16),
                    ),
                  );
                }
                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    return _buildAlertCard(alerts[index]);
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}