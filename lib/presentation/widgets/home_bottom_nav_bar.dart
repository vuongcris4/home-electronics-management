// lib/presentation/widgets/home_bottom_nav_bar.dart
import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF2666DE);

class HomeBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(asset: 'assets/icons/document.png', index: 0, context: context), // Alerts
          _buildNavItem(asset: 'assets/icons/home.png', index: 1, context: context),     // Home
          _buildNavItem(asset: 'assets/icons/profile.png', index: 2, context: context),  // Profile
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String asset,
    required int index,
    required BuildContext context,
  }) {
    final isSelected = currentIndex == index; // Sáng màu icon currentIndex
    return IconButton(
      icon: Image.asset(
        asset,
        width: 30,
        height: 30,
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
      ),
      onPressed: () => onTap(index),  // Khi nhấn NavItem thì ở màn cha, _selectedIndex = NavItem index hiện tại. 
    );
  }
}