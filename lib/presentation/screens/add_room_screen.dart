import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';

// --- Hằng số màu sắc ---
const Color kPrimaryColor = Color(0xFF2666DE);
const Color kBorderColor = Color(0xFFCFCFCF);
const Color kLabelColor = Color(0xFF13304A); // Màu chữ tiêu đề và label

class AddRoomScreen extends StatefulWidget {
  const AddRoomScreen({super.key});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- Hàm xử lý logic khi nhấn nút "Add" ---
  void _addRoom() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Room name cannot be empty.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final provider = Provider.of<HomeProvider>(context, listen: false);
    final success = await provider.addNewRoom(_nameController.text.trim());

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add room: ${provider.errorMessage}'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<HomeProvider>().isLoadingAction;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(35.0, 0, 35.0, 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon:
                      const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add Room',
                textAlign: TextAlign.center,
                style: TextStyle(
                  // --- SỬA 1: Dùng màu chữ đã định nghĩa ---
                  color: kLabelColor,
                  fontSize: 32,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              // --- SỬA 2: Dùng Spacer để đẩy nội dung vào giữa ---
              const Spacer(),

              _CustomTextField(
                label: 'Room',
                hint: 'Enter Your Room',
                controller: _nameController,
              ),
              const SizedBox(height: 60),

              // --- SỬA 3: Cập nhật đường dẫn và màu sắc icon ---
              Image.asset(
                'assets/icons/house_icon.png', // Hãy chắc chắn đường dẫn này đúng
                height: 140,
                color: const Color(0xFF8FA9D6), // Màu xanh nhạt chính xác
              ),

              // --- SỬA 4: Dùng Spacer để đẩy nút xuống dưới cùng ---
              const Spacer(),

              ElevatedButton(
                onPressed: isLoading ? null : _addRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 19),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        // --- SỬA 5: Đổi chữ trên nút ---
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Widget tùy chỉnh cho TextField, không cần thay đổi ---
class _CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _CustomTextField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        TextField(
          controller: controller,
          autofocus: true,
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
