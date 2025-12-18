// lib/presentation/screens/alerts_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/home_header.dart';

const Color kPrimaryColor = Color(0xFF2666DE);

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  /// Widget to build each log/alert card.
  Widget _buildAlertCard(AlertLog alert) {
    // [UPDATE] Vì chỉ còn type Info nên không cần check warning nữa
    // Luôn sử dụng style mặc định (nền trắng, icon xanh)
    const Color cardColor = Colors.white;
    const Color iconColor = kPrimaryColor;
    const IconData iconData = Icons.info_outline;

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
          const Icon(iconData, color: iconColor, size: 24),
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
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER
          const HomeHeader(),
          
          const SizedBox(height: 24),

          // Activity logs Title
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
          
          // LIST OF LOGS
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