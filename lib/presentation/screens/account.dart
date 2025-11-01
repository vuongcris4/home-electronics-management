// lib/presentation/screens/account.dart

// --- IMPORT ---
// Import thư viện Material UI cơ bản của Flutter
import 'package:flutter/material.dart';
// Import thư viện để lưu trữ an toàn (như access token)
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Import Provider để quản lý state
import 'package:provider/provider.dart';
// Import định nghĩa (entity) của User
import '../../domain/entities/user.dart';
// Import file injection_container (dùng cho Service Locator, ví dụ 'getIt')
import '../../injection_container.dart';
// Import AuthProvider để quản lý state liên quan đến xác thực (user, login, logout)
import '../providers/auth_provider.dart';
// Import HomeProvider để quản lý state của màn hình home (rooms, devices)
import '../providers/home_provider.dart';

// ==========================================================
// CONSTANTS (HẰNG SỐ)
// ==========================================================
// Định nghĩa các màu sắc cố định để sử dụng trong màn hình này
const Color kBackgroundColor = Color(0xFFF2F6FC);
const Color kPrimaryColor = Color(0xFF2666DE);
const Color kTextColor = Color(0xFF6F7EA8);
const Color kCardColor = Colors.white;

// ==========================================================
// MAIN WIDGET: ProfileScreen
// ==========================================================
// Đây là một StatefulWidget vì nó cần quản lý state (ví dụ: khởi tạo việc fetch data)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// Đây là class chứa State của ProfileScreen
class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // initState được gọi 1 lần khi widget được tạo
    // Dùng WidgetsBinding.instance.addPostFrameCallback để đảm bảo context đã sẵn sàng
    // trước khi gọi Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Lấy AuthProvider (listen: false vì ta chỉ muốn gọi hàm, không cần build lại)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Chỉ fetch (tải) thông tin user nếu hiện tại chưa có
      if (authProvider.user == null) {
        authProvider.fetchUserProfile();
      }
    });
  }

  /// Hàm xử lý logic Đăng xuất
  Future<void> _logout(BuildContext context) async {
    // Lấy instance của FlutterSecureStorage từ 'getIt'
    final storage = getIt<FlutterSecureStorage>();
    // Xóa access token và refresh token đã lưu
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');

    // Kiểm tra 'context.mounted' để đảm bảo widget vẫn còn trên cây UI
    if (context.mounted) {
      // Xóa dữ liệu người dùng trong AuthProvider
      Provider.of<AuthProvider>(context, listen: false).clearUserData();
      // Xóa dữ liệu local (rooms, devices) trong HomeProvider
      await Provider.of<HomeProvider>(context, listen: false).clearLocalData();

      // Điều hướng về màn hình Login và xóa tất cả các màn hình cũ khỏi stack
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  // ===================== THÊM MỚI =====================
  /// Hiển thị một hộp thoại (Dialog) để sửa thông tin profile
  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    // Controller để lấy/đặt text cho ô Full Name
    final nameController = TextEditingController(text: authProvider.user?.name);
    // Controller để lấy/đặt text cho ô Phone Number
    final phoneController =
    TextEditingController(text: authProvider.user?.phoneNumber);
    // GlobalKey để quản lý trạng thái của Form (ví dụ: để validate)
    final formKey = GlobalKey<FormState>();

    // Hiển thị một Dialog
    showDialog(
      context: context,
      builder: (dialogContext) { // 'dialogContext' là context của riêng Dialog này
        return AlertDialog(
          title: const Text('Edit Profile'),
          // Nội dung của Dialog là một Form
          content: Form(
            key: formKey, // Gắn key cho Form
            child: Column(
              mainAxisSize: MainAxisSize.min, // Giúp Column co lại vừa bằng nội dung
              children: [
                // Ô nhập Full Name
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  // Validator để kiểm tra lỗi
                  validator: (value) =>
                  value!.isEmpty ? 'Name cannot be empty' : null,
                ),
                // Ô nhập Phone Number
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  validator: (value) =>
                  value!.isEmpty ? 'Phone cannot be empty' : null,
                ),
              ],
            ),
          ),
          // Các nút hành động (Cancel, Save)
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Đóng Dialog
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Kiểm tra xem Form có hợp lệ không
                if (formKey.currentState!.validate()) {
                  // Gọi hàm updateProfile từ AuthProvider
                  final success = await authProvider.updateProfile(
                    name: nameController.text,
                    phoneNumber: phoneController.text,
                  );
                  // Kiểm tra dialogContext.mounted trước khi tương tác
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext); // Đóng Dialog
                    // Nếu update thất bại, hiển thị SnackBar lỗi
                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Update failed: ${authProvider.errorMessage}')),
                      );
                    }
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  // ===================== KẾT THÚC =====================

  @override
  Widget build(BuildContext context) {
    // Sử dụng Consumer<HomeProvider> để "lắng nghe" thay đổi từ HomeProvider
    // và build lại khi HomeProvider thay đổi (ví dụ: số lượng devices)
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        // Tính toán tổng số thiết bị
        final totalDevices = homeProvider.rooms
            .fold<int>(0, (sum, room) => sum + room.devices.length);
        // Tính toán số thiết bị đang BẬT
        final devicesOn = homeProvider.rooms.fold<int>(
            0,
                (sum, room) =>
            sum + room.devices.where((d) => d.isOn).length);
        // Tính toán số thiết bị đang TẮT
        final devicesOff = totalDevices - devicesOn;

        // Sử dụng Consumer<AuthProvider> lồng bên trong
        // để "lắng nghe" thay đổi từ AuthProvider (ví dụ: khi profile được tải xong)
        return Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user; // Lấy thông tin user
            final profileState = authProvider.profileState; // Lấy trạng thái (Loading, Success, Error)

            return Scaffold(
              backgroundColor: kBackgroundColor, // Đặt màu nền
              // SafeArea đảm bảo nội dung không bị che
              body: SafeArea(
                bottom: false, // Không áp dụng SafeArea cho cạnh dưới
                // Column chính chứa toàn bộ màn hình
                child: Column(
                  children: [
                    // HEADER: Chứa nút Logout
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end, // Đẩy nút về bên phải
                        children: [
                          SizedBox(
                            width: 44,
                            height: 44,
                            // Nút bấm đăng xuất
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Image.asset('assets/icons/exit.png',), // Icon đăng xuất
                              onPressed: () => _logout(context), // Gọi hàm _logout khi nhấn
                            ),
                          ),
                        ],
                      ),
                    ),

                    // AVATAR
                    const SizedBox(height: 20), // Khoảng cách
                    _buildAvatar(), // Gọi widget helper để build avatar
                    const SizedBox(height: 15), // Khoảng cách

                    // Tên và Email (Hiển thị có điều kiện)
                    // Nếu đang tải -> Hiển thị vòng xoay
                    if (profileState == ViewState.Loading)
                      const CircularProgressIndicator(),
                    // Nếu tải thành công VÀ user không null -> Hiển thị thông tin
                    if (profileState == ViewState.Success && user != null)
                      _buildUserInfo(user, authProvider),
                    // Nếu tải lỗi -> Hiển thị thông báo lỗi
                    if (profileState == ViewState.Error)
                      const Text("Failed to load profile",
                          style: TextStyle(color: Colors.red)),

                    const SizedBox(height: 30), // Khoảng cách

                    // ===================== THAY ĐỔI Ở ĐÂY =====================
                    // INFO CARDS GRID (Thống kê)
                    // Expanded giúp phần này lấp đầy không gian còn lại
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        // GridView.count tạo một lưới có 2 cột
                        child: GridView.count(
                          crossAxisCount: 2,    // 2 cột
                          crossAxisSpacing: 20, // Khoảng cách ngang giữa các item
                          mainAxisSpacing: 20,  // Khoảng cách dọc giữa các item
                          physics: const NeverScrollableScrollPhysics(), // Không cho phép cuộn GridView
                          children: [
                            // 4 thẻ thông tin
                            _buildInfoCard(
                                devicesOn.toString(), 'Devices On'),
                            _buildInfoCard(
                                devicesOff.toString(), 'Devices Off'),
                            _buildInfoCard(
                                homeProvider.rooms.length.toString(), 'Rooms'),
                            _buildInfoCard(totalDevices.toString(), 'Total Devices'),
                          ],
                        ),
                      ),
                    ),
                    // ===================== KẾT THÚC THAY ĐỔI =====================
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget helper để hiển thị thông tin người dùng và nút edit
  Widget _buildUserInfo(User user, AuthProvider authProvider) {
    return Column(
      children: [
        // Row chứa [Khoảng đệm] [Tên] [Nút Edit]
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Căn giữa Row
          children: [
            // 1. KHOẢNG TRỐNG VÔ HÌNH (BÊN TRÁI)
            // Dùng 1 SizedBox với chiều rộng bằng kích thước nút (48.0)
            // để "đánh lừa" Row, làm cho Tên (ở giữa) được căn giữa màn hình
            const SizedBox(width: 48.0),

            // 2. TÊN CỦA BẠN (GIỜ SẼ Ở GIỮA)
            Text(
              user.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6F7EA8),
                fontSize: 22,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),

            // 3. NÚT EDIT THẬT (BÊN PHẢI)
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: kTextColor),
              onPressed: () => _showEditProfileDialog(context, authProvider), // Mở dialog khi nhấn
            )
          ],
        ),
        const SizedBox(height: 4), // Khoảng cách
        // Hiển thị email
        Text(
          user.email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF9DB2CE),
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  // Widget helper để build các thẻ thống kê (Devices On, Rooms...)
  Widget _buildInfoCard(String value, String label) {
    return Container(
      decoration: ShapeDecoration(
        color: kCardColor, // Màu nền thẻ
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(19.02), // Bo góc
        ),
        shadows: const [ // Đổ bóng
          BoxShadow(
            color: Color(0x0C3880F6),
            blurRadius: 30.43,
            offset: Offset(0, 10.46),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Căn giữa nội dung thẻ
        children: [
          // Giá trị (ví dụ: "5")
          Text(
            value,
            style: const TextStyle(
              color: kTextColor,
              fontSize: 32,
              fontFamily: 'Inter',
              height: 0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8), // Khoảng cách
          // Nhãn (ví dụ: "Devices On")
          Text(
            label,
            style: const TextStyle(
              color: kTextColor,
              fontSize: 20,
              fontFamily: 'Inter',
              height: 0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper để build avatar (hiện là placeholder)
  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Vòng tròn nền gradient
        Container(
          width: 110.31,
          height: 110.31,
          decoration: const ShapeDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.00, -1.00),
              end: Alignment(0, 1),
              colors: [Color(0xFFDEEFFF), Color(0xFFBCDEFF)],
            ),
            shape: OvalBorder(),
          ),
        ),
        // Placeholder for avatar image (Bạn có thể thêm Image.network(...) ở đây)
      ],
    );
  }
}