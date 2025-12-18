// Lưu Ngọc Thiện

// Import thư viện
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Định nghĩa màn hình SignUpSuccessScreen (Đăng ký thành công) là một StatelessWidget.
// Nó là "Stateless" (không có trạng thái) vì màn hình này chỉ hiển thị
// thông tin tĩnh và không có trạng thái nội tại nào cần quản lý (như text input hay checkbox).
class SignUpSuccessScreen extends StatelessWidget {
  // Constructor (hàm khởi tạo) cho SignUpSuccessScreen.
  const SignUpSuccessScreen({super.key});

  @override
  // Ghi đè phương thức build, đây là nơi giao diện (UI) được xây dựng.
  Widget build(BuildContext context) {
    // Trả về Scaffold, cấu trúc cơ bản cho một màn hình.
    return Scaffold(
      // Đặt màu nền của màn hình là màu trắng.
      backgroundColor: Colors.white,
      // Phần thân (body) của Scaffold.
      body: Container(
        // Trang trí cho Container.
        decoration: BoxDecoration(
          // Bo góc 40
          borderRadius: BorderRadius.circular(40),
        ),
        // Sử dụng Stack để xếp chồng các widget.
        // Mặc dù ở đây chỉ có 1 con là Column, Stack vẫn được dùng,
        // có thể để dự phòng cho việc thêm các element trang trí sau này (ví dụ: confetti).
        child: Stack(
          children: [
            // Sắp xếp các widget con theo chiều dọc.
            Column(
              children: [
                // Tạo một khoảng trống dọc, cao 221 (pixel).
                const SizedBox(height: 221),
                // Căn giữa widget con của nó (là SizedBox chứa ảnh SVG).
                Center(
                  child: SizedBox(
                    // Đặt kích thước cố định cho ảnh.
                    width: 157.067,
                    height: 155.414,
                    // Widget để hiển thị ảnh SVG từ thư mục assets.
                    child: SvgPicture.asset(
                      'assets/img/User_Check.svg', // Đường dẫn tới file SVG.
                      // 'fit: BoxFit.contain' đảm bảo ảnh nằm trọn vẹn
                      // bên trong SizedBox mà không bị méo.
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Khoảng đệm dọc.
                const SizedBox(height: 86.586),
                // Căn giữa widget Text.
                const Center(
                  child: Text(
                    'Successfully!!!', // Nội dung text.
                    // Định nghĩa style cho text.
                    style: TextStyle(
                      fontSize: 40, // Cỡ chữ
                      fontWeight: FontWeight.w500, // Độ đậm
                      letterSpacing: 0.28, // Khoảng cách ký tự
                      color: Color(0xFF2754A5), // Màu chữ
                      height: 1.0, // Chiều cao dòng (sát).
                    ),
                    textAlign: TextAlign.center, // Căn giữa text (nếu có nhiều dòng).
                  ),
                ),
                // Khoảng đệm dọc.
                const SizedBox(height:86.59), 
                // Container để tạo kiểu dáng (style) cho nút bấm "Log in".
                Container(
                  // Thêm margin (lề) 31px ở hai bên trái/phải.
                  margin: const EdgeInsets.symmetric(horizontal: 31),
                  // Chiều rộng lấp đầy (trừ đi margin).
                  width: double.infinity,
                  // Chiều cao cố định 60px.
                  height: 60,
                  // Trang trí cho Container (nền của nút).
                  decoration: BoxDecoration(
                    color: const Color(0xFF2666DE), // Màu nền.
                    borderRadius: BorderRadius.circular(32), // Bo góc 32.
                    // Thêm hiệu ứng đổ bóng.
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2666DE).withOpacity(0.3),
                        offset: const Offset(0, 4),
                        blurRadius: 12, // Độ mờ
                        spreadRadius: 0, // Độ lan toả
                      ),
                    ],
                  ),
                  // Sử dụng MaterialButton để cung cấp chức năng nhấn và hiệu ứng ripple.
                  child: MaterialButton(
                    // Hàm được gọi khi nhấn nút.
                    onPressed: () {
                      // Điều hướng đến màn hình '/login'.
                      // 'pushNamedAndRemoveUntil' sẽ đẩy màn hình '/login' lên
                      // và gỡ bỏ tất cả các màn hình trước đó (do (route) => false).
                      // Điều này ngăn người dùng nhấn "Back" quay lại màn hình
                      // Success hoặc màn hình Đăng ký.
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    },
                    // Định hình cho MaterialButton (để khớp với Container).
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    // Nội dung (con) của nút, là một widget Text.
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}