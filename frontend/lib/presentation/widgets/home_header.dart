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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
      // trang trí cho container
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
              // Tháng ngày năm góc trái trên dùng
              Text(
                DateFormat('MMMM d, yyyy').format(DateTime.now()),
                style:
                    const TextStyle(color: kTextColorSecondary, fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                'QL Thiết bị điện',
                style: TextStyle(
                  color: kTextColorPrimary,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Nút logout
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
                padding: EdgeInsets.zero,
                icon: Image.asset(
                  'assets/icons/exit.png',
                ),
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout(context);
                }),
          ),
        ],
      ),
    );
  }
}
