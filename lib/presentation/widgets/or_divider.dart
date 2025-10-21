// lib/presentation/widgets/or_divider.dart
import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: Container(
              height: 2,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [Color(0xFF0B6EFE), Color(0x00C4C4C4)])))),
      const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Or Log in With',
              style: TextStyle(
                  color: Color(0xFF555151), fontSize: 12, fontFamily: 'Outfit'))),
      Expanded(
          child: Container(
              height: 2,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF0B6EFE), Color(0x00C4C4C4)]))))
    ]);
  }
}