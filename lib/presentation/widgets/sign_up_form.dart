//Lưu Ngọc Thiện

// lib/presentation/widgets/sign_up_form.dart

// Import các thư viện 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// Định nghĩa SignUpForm là một StatefulWidget.
// Nó "Stateful" vì cần quản lý trạng thái của các ô nhập liệu
// (TextEditingController) và trạng thái ẩn/hiện mật khẩu.
class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  // Tạo đối tượng State cho widget này.
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  // Tạo các Controller để quản lý text cho từng ô input.
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Biến state để theo dõi trạng thái ẩn/hiện của mật khẩu.
  bool _isPasswordVisible = false;

  @override
  // Hàm dispose được gọi khi widget bị gỡ khỏi cây widget.
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    // Gọi hàm dispose của lớp cha.
    super.dispose();
  }


  // Hàm xử lý logic khi người dùng nhấn nút "Sign Up" (Đăng ký).
  // `async` vì nó sẽ gọi một hàm bất đồng bộ (await authProvider.register).
  void _signUp() async {
    // Kiểm tra xem widget có còn "mounted" (gắn vào cây) không.
    // Nếu không (ví dụ: người dùng đã back), thì `return` để dừng hàm.
    if (!mounted) return;
    // Kiểm tra (validate) xem mật khẩu và mật khẩu xác nhận có khớp không.
    if (_passwordController.text != _confirmPasswordController.text) {
      // Nếu không khớp, hiển thị một SnackBar thông báo lỗi.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu không khớp!")),
      );
      return;
    }

    // Lấy AuthProvider từ cây widget.
    // `listen: false` vì chúng ta chỉ muốn GỌI HÀM, không cần widget này
    // build lại khi AuthProvider thay đổi (chúng ta sẽ dùng `context.watch` trong `build` để làm việc đó).
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Gọi hàm `register` từ provider và chờ (await) kết quả (true/false).
    // `trim()` để cắt bỏ khoảng trắng ở đầu/cuối chuỗi.
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      password2: _confirmPasswordController.text, // Xác nhận mật khẩu 
      phoneNumber: _phoneController.text.trim(),
    );


    // Sau khi `await`, cần kiểm tra lại `mounted` một lần nữa,
    // vì người dùng có thể đã rời màn hình trong khi chờ kết quả mạng.
    if (!mounted) return;

    // Nếu đăng ký thành công (success == true).
    if (success) {
      // Điều hướng đến màn hình '/signup-success' (thành công).
      // `pushNamedAndRemoveUntil` sẽ đẩy màn hình mới lên và
      // gỡ bỏ tất cả các màn hình trước đó (route) => false,
      // để người dùng không thể nhấn "Back" quay lại màn hình đăng ký/đăng nhập.
      Navigator.pushNamedAndRemoveUntil(
          context, '/signup-success', (route) => false);
    } else {
      // Nếu đăng ký thất bại.
      // Hiển thị SnackBar với thông báo lỗi lấy từ provider.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Đăng ký thất bại: ${authProvider.errorMessage}')),
      );
    }
  }

  @override
  // Hàm `build` chịu trách nhiệm xây dựng giao diện (UI).
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình.
    final screenSize = MediaQuery.of(context).size;

    // Lấy trạng thái loading từ AuthProvider.
    // `context.watch` sẽ "lắng nghe" sự thay đổi của AuthProvider.
    // Khi `registerState` thay đổi (ví dụ: từ Idle -> Loading),
    // widget này sẽ tự động build lại.
    final isLoading = context.watch<AuthProvider>().registerState == ViewState.Loading;
    // Trả về một `Column` để sắp xếp các ô input và nút bấm theo chiều dọc.
    return Column(
      children: [
        _buildInputField(label: 'Name', hintText: 'Your Name', controller: _nameController),
        const SizedBox(height: 24),
        _buildInputField(label: 'Email Address', hintText: 'Enter Your Email', controller: _emailController, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 24),
        _buildInputField(label: 'Password', hintText: 'Enter Your Password', isPassword: true, controller: _passwordController),
        const SizedBox(height: 24),
        _buildInputField(label: 'Confirm Password', hintText: 'Confirm Your Password', isPassword: true, controller: _confirmPasswordController),
        const SizedBox(height: 24),
        _buildInputField(label: 'Phone No.', hintText: '+84', controller: _phoneController, keyboardType: TextInputType.phone),
        SizedBox(height: screenSize.height * 0.0493),
        Container(
          width: screenSize.width * 0.84, // Chiều rộng 84% màn hình.
          height: 56, // Chiều cao cố định.
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(32), color: const Color(0xFF2666DE), boxShadow: [BoxShadow(color: const Color(0xFF2666DE).withOpacity(0.3), offset: const Offset(0, 4), blurRadius: 12, spreadRadius: 0)]),
          
          // Sử dụng `MaterialButton` để có hiệu ứng "ripple" khi nhấn.
          child: MaterialButton(
            // Nếu `isLoading` là true, `onPressed` là `null` (vô hiệu hóa nút).
            // Nếu không, gán hàm `_signUp` để thực thi khi nhấn.
            onPressed: isLoading ? null : _signUp,
            // Nội dung (con) của nút.
            child: isLoading
                // Nếu đang loading: hiển thị vòng xoay.
                ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                // Nếu không loading: hiển thị chữ "Create".
                : const Text('Create', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.09)),
          ),
        ),
      ],
    );
  }

  // Hàm trợ giúp (helper method) để tạo một ô input field.
  // Giúp tái sử dụng code và làm cho hàm `build` gọn gàng hơn.
  Widget _buildInputField({
    required String label, //Nhãn
    required String hintText, //Chữ gợi ý
    required TextEditingController controller, // Controller tương ứng.
    bool isPassword = false, // Mặc định không phải là ô mật khẩu.
    TextInputType? keyboardType, // Kiểu bàn phím (nếu có).
  }) {
    // Sắp xếp nhãn (label) và ô input (TextFormField) theo chiều dọc.
    return Column(
      // Căn chỉnh các con (Text, TextFormField) sang bên trái.
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thêm đệm cho nhãn (label).
        Padding(padding: const EdgeInsets.only(left: 12, bottom: 8), child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF14304A), letterSpacing: 0.07))),
        // Giới hạn chiều cao của TextFormField.
        SizedBox(
          height: 48,
          // Widget ô nhập liệu chính.
          child: TextFormField(
            controller: controller, // Gắn controller.
            keyboardType: keyboardType, // Đặt kiểu bàn phím.
            // Nếu là ô mật khẩu (isPassword == true) VÀ 
            // `_isPasswordVisible` là false, thì che text (hiển thị dấu •••).
            obscureText: isPassword && !_isPasswordVisible,
            // Style cho chữ người dùng nhập vào.
            style: const TextStyle(fontSize: 16, color: Color(0xFF14304A), letterSpacing: 0.112),
            // Trang trí (decoration) cho ô input.
            decoration: InputDecoration(
              hintText: hintText, // Chữ gợi ý
              hintStyle: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.112),
              filled: true, // cho phép tô màu nền 
              fillColor: Colors.white, // Màu nền là trắng.
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              // Định nghĩa đường viền (border) chung.
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: const BorderSide(color: Color(0xFFCFCFCF), width: 1)),
              // Đường viền khi ô input được bật (enabled) nhưng không focus.
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: const BorderSide(color: Color(0xFFCFCFCF), width: 1)),
              // Đường viền khi ô input đang được focus (nhấn vào).
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: const BorderSide(color: Color(0xFF2666DE), width: 1)),
              // Icon ở phía sau (bên phải) của ô input.
              suffixIcon: isPassword // Chỉ hiển thị nếu đây là ô mật khẩu.
                  // Nếu đúng, tạo một IconButton (nút có icon).
                  ? IconButton(
                      padding: const EdgeInsets.only(right: 20),
                      // Chọn icon dựa trên `_isPasswordVisible`:
                      // `visibility_outlined` (mắt mở) nếu đang hiển thị.
                      // `visibility_off_outlined` (mắt gạch chéo) nếu đang ẩn.
                      icon: Icon(_isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFFCFCFCF), size: 20),
                      // Khi nhấn vào icon:
                      // Gọi `setState` để cập nhật UI.
                      // Đảo ngược giá trị của `_isPasswordVisible` (true -> false, false -> true).
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    )
                  // Nếu không phải ô mật khẩu, không hiển thị icon gì (null).
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}