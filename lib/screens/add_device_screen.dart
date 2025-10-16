import 'package:flutter/material.dart';

// --- Các hằng số màu sắc và style cho nhất quán ---
const Color kPrimaryColor = Color(0xFF2666DE);
const Color kTextColorSecondary = Color(0xFF6F7EA8);
const Color kBorderColor = Color(0xFFCFCFCF);
const Color kLabelColor = Color(0xFF13304A);

class AddDeviceScreen extends StatelessWidget {
  const AddDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // *** BỎ HOÀN TOÀN APPBAR Ở ĐÂY ***

      // *** THAY ĐỔI CHÍNH ***
      // 1. Dùng SafeArea để tránh thanh trạng thái (cột sóng, pin...)
      // 2. Nút "Trở về" bây giờ là item đầu tiên trong Column,
      //    làm cho nó cuộn cùng với phần còn lại của màn hình.
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- NÚT TRỞ VỀ ĐƯỢC ĐƯA VÀO ĐÂY ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                const SizedBox(height: 20),
                // --- Tiêu đề ---
                const Text(
                  'Add Device',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF404040),
                    fontSize: 32,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 60),

                // --- Các ô nhập liệu ---
                const _CustomTextField(label: 'Name Device', hint: 'Name Device'),
                const SizedBox(height: 30),
                const _CustomTextField(label: 'Room', hint: 'Bedroom'),
                const SizedBox(height: 30),
                const _CustomTextField(label: 'Note', hint: 'Note'),
                const SizedBox(height: 60),

                // --- Tiêu đề phần chọn Icon ---
                const Text(
                  'Select Icon',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),

                // --- Widget cuộn ngang cho các Icon ---
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: _IconSelectionButton(icon: Icons.music_note, label: 'Music', isSelected: false),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: _IconSelectionButton(icon: Icons.air, label: 'Cooler', isSelected: false),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: _IconSelectionButton(icon: Icons.lightbulb_outline, label: 'Light', isSelected: true),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: _IconSelectionButton(icon: Icons.wifi, label: 'Wifi', isSelected: false),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: _IconSelectionButton(icon: Icons.power, label: 'Other', isSelected: false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),

                // --- Nút Add ---
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 19),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Widget tách riêng cho ô nhập liệu (KHÔNG THAY ĐỔI) ---
class _CustomTextField extends StatelessWidget {
  final String label;
  final String hint;

  const _CustomTextField({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: kBorderColor),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 19),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: const BorderSide(color: kBorderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
            ),
          ),
        ),
        Positioned(
          left: 40,
          top: -10,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label,
              style: const TextStyle(
                color: kLabelColor,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Widget tách riêng cho các nút chọn icon (KHÔNG THAY ĐỔI) ---
class _IconSelectionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _IconSelectionButton({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 67,
          height: 67,
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                      color: Color(0x5B3880F6),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ]
                : [],
            border: isSelected ? null : Border.all(color: kBorderColor.withOpacity(0.5))
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : kTextColorSecondary,
            size: 30,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? kPrimaryColor : kTextColorSecondary,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
  }
}