// Lưu Ngọc Thiện

// lib/presentation/screens/sign_up_screen.dart
// Import thư viện Material của Flutter để sử dụng các widget UI cơ bản.
import 'package:flutter/material.dart';
import '../widgets/sign_up_form.dart';

// Định nghĩa màn hình SignUpScreen là một StatelessWidget.
// Nó là "Stateless" (không có trạng thái) vì màn hình này chỉ
// chịu trách nhiệm hiển thị layout. Trạng thái (như text đang nhập)
// sẽ được quản lý bên trong 'SignUpForm'.
class SignUpScreen extends StatelessWidget {
  // Constructor (hàm khởi tạo) cho SignUpScreen.
  const SignUpScreen({super.key});

  // Ghi đè phương thức build, đây là nơi giao diện (UI) được xây dựng.
  @override
  Widget build(BuildContext context) {
    // Lấy thông tin kích thước của màn hình (chiều rộng, chiều cao).
    // 'MediaQuery.of(context).size' trả về một đối tượng Size.
    final screenSize = MediaQuery.of(context).size;
    
    // Tính toán padding (khoảng đệm) ngang dựa trên tỷ lệ phần trăm chiều rộng màn hình.
    // 0.0771 tương đương với 7.71% chiều rộng màn hình.
    // Cách làm này giúp UI tương thích (responsive) với nhiều kích cỡ màn hình khác nhau.
    final horizontalPadding = screenSize.width * 0.0771;

    // Trả về Scaffold, cấu trúc cơ bản cho một màn hình.
    return Scaffold(
      // Đặt màu nền của màn hình là màu trắng.
      backgroundColor: Colors.white,
      // Định nghĩa thanh AppBar (thanh ứng dụng ở trên cùng).
      appBar: AppBar(
        // Đặt màu nền của AppBar là trong suốt.
        backgroundColor: Colors.transparent,
        // Đặt 'elevation' (độ cao, hiệu ứng đổ bóng) là 0 để làm cho nó phẳng.
        elevation: 0,
        // Định nghĩa widget 'leading' (widget ở bên trái cùng của AppBar).
        leading: Padding(
          // Thêm một khoảng đệm bên trái cho nút back, cũng dựa trên tỷ lệ màn hình.
          padding: EdgeInsets.only(left: screenSize.width * 0.0615),
          // Nút bấm có icon.
          child: IconButton(
            // Sử dụng icon mũi tên quay lại (kiểu iOS).
            icon: const Icon(Icons.arrow_back_ios,
                color: Color(0xFF14304A), // Đặt màu cho icon.
                size: 24 // Đặt kích thước icon.
                ),
            // Hàm được gọi khi nhấn nút.
            // 'Navigator.maybePop(context)' sẽ đóng màn hình hiện tại (pop)
            // chỉ khi có thể (tức là có màn hình trước đó trong "ngăn xếp" navigation).
            // An toàn hơn 'Navigator.pop(context)'.
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
      ),
      // Phần thân (body) của Scaffold.
      // Sử dụng 'SingleChildScrollView' để cho phép nội dung cuộn
      // khi bàn phím ảo hiện lên (tránh lỗi "bottom overflowed").
      body: SingleChildScrollView(
        // Thêm khoảng đệm (padding) cho nội dung bên trong.
        // 'symmetric(horizontal: ...)' áp dụng padding cho cả bên trái và bên phải.
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          // Sắp xếp các widget con theo chiều dọc.
          child: Column(
            // Danh sách các widget con.
            children: [
              // Tạo một khoảng trống dọc, chiều cao bằng 4% chiều cao màn hình.
              SizedBox(height: screenSize.height * 0.04), // Reduced from 0.0821
              // Widget Text hiển thị tiêu đề "Create Account".
              const Text('Create Account',
                  // Định nghĩa style cho text.
                  style: TextStyle(
                      color: Color(0xFF13304A), // Màu chữ
                      fontSize: 28, // Cỡ chữ
                      fontFamily: 'Inter', // Font chữ
                      fontWeight: FontWeight.w600, // Độ đậm
                      letterSpacing: 0.14 // Khoảng cách giữa các ký tự
                      ),
                  textAlign: TextAlign.center // Căn giữa text
                  ),
              // Một khoảng đệm dọc nhỏ.
              const SizedBox(height: 12),
              // Widget Text hiển thị mô tả/phụ đề.
              const Text(
                  'Fill your information below or register\nwith your social account', // '\n' để xuống dòng.
                  textAlign: TextAlign.center, // Căn giữa.
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFC4C4C4), // Màu xám.
                      letterSpacing: 0.06,
                      height: 1.5 // Chiều cao dòng (tăng khoảng cách giữa 2 dòng).
                      )),
              // Một khoảng đệm dọc, bằng 5% chiều cao màn hình.
              SizedBox(height: screenSize.height * 0.05), // Reduced from 0.0654
              
              // Đây là nơi widget 'SignUpForm' (đã import ở trên) được chèn vào.
              // Widget này sẽ chứa các ô TextField cho email, password, v.v.
              // và logic xử lý của riêng nó.
              const SignUpForm(),
              
              // Một khoảng đệm 40px ở dưới cùng của Column.
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}