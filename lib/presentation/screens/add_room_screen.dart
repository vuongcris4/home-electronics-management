import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';

// --- Hằng số màu sắc ---
const Color kPrimaryColor = Color(0xFF2666DE);
const Color kBorderColor = Color(0xFFCFCFCF);
const Color kLabelColor = Color(0xFF13304A); // Màu chữ tiêu đề và label

// Màn hình UI (thuộc Presentation Layer) cho phép người dùng nhập tên và thêm phòng mới.
// Màn hình này sẽ tương tác với HomeProvider để thực hiện logic.
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

  // --- Hàm xử lý logic chính khi người dùng nhấn nút "Add" ---
  void _addRoom() async {
    // 1. Validate: Kiểm tra xem người dùng đã nhập tên phòng chưa.
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Room name cannot be empty.'),
            backgroundColor: Colors.red),
      );
      return; // Dừng hàm nếu tên rỗng
    }

    // 2. Lấy HomeProvider (từ Presentation Layer) để gọi business logic.
    // (listen: false) vì ta chỉ cần gọi hàm, không cần build lại widget này
    // ngay tại thời điểm gọi (việc build lại sẽ do .watch() ở dưới xử lý).
    final provider = Provider.of<HomeProvider>(context, listen: false);

    // 3. Gọi hàm addNewRoom trong HomeProvider.
    // Hàm này sẽ gọi AddRoomUseCase (Domain Layer) -> Repository (Infra Layer) -> API/DB.
    // Chờ (await) cho đến khi UseCase hoàn thành và Provider cập nhật trạng thái.
    final success = await provider.addNewRoom(_nameController.text.trim());

    // 4. (Best practice) Kiểm tra xem widget còn "mounted" (tồn tại trên cây widget) hay không
    // trước khi thực hiện các thao tác liên quan đến BuildContext (như Navigator, SnackBar).
    // Điều này tránh lỗi nếu người dùng thoát màn hình TRƯỚC KHI hàm async hoàn thành.
    if (mounted) {
      if (success) {
        // 5a. Nếu thành công: Quay lại màn hình trước đó (HomeScreen).
        Navigator.of(context).pop();
      } else {
        // 5b. Nếu thất bại: Hiển thị lỗi (lỗi này được set trong HomeProvider) cho người dùng.
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
    // Lắng nghe (watch) trạng thái isLoadingAction từ HomeProvider.
    // Khi isLoadingAction thay đổi (true <-> false), widget này sẽ tự động build lại
    // để cập nhật UI (ví dụ: hiển thị vòng quay loading trên nút).
    final isLoading = context.watch<HomeProvider>().isLoadingAction;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // ================== SỬA 1: BỌC BẰNG SingleChildScrollView ==================
        // (Giúp màn hình không bị lỗi "Bottom Overflow" khi bàn phím hiện lên)
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(35.0, 0, 35.0, 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add Room',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kLabelColor,
                    fontSize: 32,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // ================== THAY THẾ Spacer ==================
                // Đã xóa "const Spacer()"
                const SizedBox(height: 40), // Thêm khoảng cách cố định

                _CustomTextField(
                  label: 'Room',
                  hint: 'Enter Your Room',
                  controller: _nameController,
                ),
                const SizedBox(height: 60),

                Image.asset(
                  'assets/icons/Home1.png',
                  height: 140,
                  color: const Color(0xFF8FA9D6),
                ),

                // ================== SỬA 3: THAY THẾ Spacer ==================
                // Đã xóa "const Spacer()"
                const SizedBox(height: 80), // Thêm khoảng cách cố định

                ElevatedButton(
                  // Vô hiệu hóa nút (onPressed = null) nếu đang tải (isLoading = true),
                  // ngược lại thì gán hàm _addRoom để thực thi khi nhấn.
                  onPressed: isLoading ? null : _addRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 19),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  // Hiển thị vòng quay loading hoặc chữ "Add" tùy thuộc vào trạng thái isLoading.
                  child: isLoading
                      ? const SizedBox(
                          height: 24, // Đặt kích thước cụ thể
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Widget tùy chỉnh cho TextField, không cần thay đổi ---
// (Widget này đã được tách riêng, không chứa logic nghiệp vụ)
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
          autofocus: true, // Tự động focus vào trường này khi màn hình mở
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