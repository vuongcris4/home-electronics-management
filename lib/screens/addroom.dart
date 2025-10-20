import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AddRoomScreen(),
    );
  }
}

class AddRoomScreen extends StatelessWidget {
  const AddRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E232C)),
                onPressed: () {
                  // Xử lý khi nhấn nút back
                },
              ),
              const SizedBox(height: 30),

              const Center(
                child: Text(
                  'Add Room',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F41BB),
                  ),
                ),
              ),
              const SizedBox(height: 70),

              // --- Sửa đổi phần Input và Label "Room" tại đây ---
              TextField(
                decoration: InputDecoration(
                  // Vị trí của label "Room" luôn nổi lên trên viền
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: 'Room', // Sử dụng labelText cho chữ "Room"
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: 'Enter Your Room',
                  hintStyle: const TextStyle(color: Colors.grey),

                  // Viền bo tròn hoàn toàn
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0), // Tăng độ bo tròn
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0), // Tăng độ bo tròn khi focus
                    borderSide: const BorderSide(color: Color(0xFF1F41BB)),
                  ),
                  // Để phần label không bị đè lên khi hintText hiển thị,
                  // có thể dùng contentPadding để điều chỉnh.
                  // Hoặc bỏ luôn hintText nếu không cần, vì labelText đã đủ ý nghĩa.
                  contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
                ),
              ),
              // --- Kết thúc sửa đổi phần Input và Label "Room" ---


              const SizedBox(height: 40),

              // --- Sửa đổi kích thước ảnh ngôi nhà tại đây ---
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/house_icon.png', // Tên file ảnh của bạn
                    width: 230,
                    height: 230,
                  ),
                ),
              ),
              // --- Kết thúc sửa đổi kích thước ảnh ngôi nhà ---

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Xử lý khi nhấn nút Add
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F41BB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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