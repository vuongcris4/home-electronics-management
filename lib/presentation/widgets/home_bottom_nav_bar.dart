// lib/presentation/widgets/home_bottom_nav_bar.dart
import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF2666DE);

class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // TODO: Thêm hành động cho các nút
          IconButton(
            icon: Image.asset('assets/icons/document.png',
                width: 30, height: 30, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Image.asset('assets/icons/home.png',
                width: 30, height: 30, color: Colors.white.withOpacity(0.5)),
            onPressed: () {},
          ),
          IconButton(
            icon: Image.asset('assets/icons/profile.png',
                width: 30, height: 30, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}