// lib/presentation/screens/account.dart

// --- IMPORT ---
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/user.dart';
import '../../injection_container.dart';
import '../providers/auth_provider.dart';
import '../providers/home_provider.dart';

// Định nghĩa các màu sắc cố định để sử dụng trong màn hình này
const Color kBackgroundColor = Color(0xFFF2F6FC);
const Color kPrimaryColor = Color(0xFF2666DE);
const Color kTextColor = Color(0xFF6F7EA8);
const Color kCardColor = Colors.white;

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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) {
        authProvider.fetchUserProfile();
      }
    });
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final nameController = TextEditingController(text: authProvider.user?.name);
    final phoneController =
        TextEditingController(text: authProvider.user?.phoneNumber);
    final formKey = GlobalKey<FormState>();

    // Hiển thị một Dialog
    showDialog(
      context: context,
      builder: (dialogContext) {
        // 'dialogContext' là context của riêng Dialog này
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Form(
            key: formKey, // Gắn key cho Form
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sửa tên
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Name cannot be empty' : null,
                ),

                // Sửa số điện thoại
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  validator: (value) =>
                      value!.isEmpty ? 'Phone cannot be empty' : null,
                ),
              ],
            ),
          ),
          actions: [
            // Nút Cancel
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            // Nút Save
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
                    Navigator.pop(dialogContext);
                    // Nếu update thất bại, hiển thị SnackBar lỗi
                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Update failed: ${authProvider.errorMessage}')),
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
            0, (sum, room) => sum + room.devices.where((d) => d.isOn).length);
        // Tính toán số thiết bị đang TẮT
        final devicesOff = totalDevices - devicesOn;

        // Sử dụng Consumer<AuthProvider> lồng bên trong
        // để "lắng nghe" thay đổi từ AuthProvider (ví dụ: khi profile được tải xong)
        return Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user; // Lấy thông tin user
            final profileState = authProvider
                .profileState; // Lấy trạng thái (Loading, Success, Error)

            return Scaffold(
              backgroundColor: kBackgroundColor, // Đặt màu nền
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Nút Logout góc phải trên cùng
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Image.asset(
                                'assets/icons/exit.png',
                              ),
                              onPressed: () {
                                Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .logout(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // HÌNH ĐẠI DIỆN
                    const SizedBox(height: 20),
                    _buildAvatar(), // Gọi widget helper để build avatar
                    const SizedBox(height: 15),

                    // TÊN
                    if (profileState == ViewState.Loading)
                      const CircularProgressIndicator(),
                    if (profileState == ViewState.Success && user != null)
                      _buildUserInfo(user, authProvider), // Các thông tin
                    if (profileState == ViewState.Error)
                      const Text("Failed to load profile",
                          style: TextStyle(color: Colors.red)),

                    const SizedBox(height: 30),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        // GridView.count tạo một lưới có 2 cột
                        child: GridView.count(
                          crossAxisCount: 2, // 2 cột
                          crossAxisSpacing:
                              20, // Khoảng cách ngang giữa các item
                          mainAxisSpacing: 20, // Khoảng cách dọc giữa các item
                          physics:
                              const NeverScrollableScrollPhysics(), // Không cho phép cuộn GridView
                          children: [
                            // 4 thẻ thông tin
                            _buildInfoCard(devicesOn.toString(), 'Devices On'),
                            _buildInfoCard(
                                devicesOff.toString(), 'Devices Off'),
                            _buildInfoCard(
                                homeProvider.rooms.length.toString(), 'Rooms'),
                            _buildInfoCard(
                                totalDevices.toString(), 'Total Devices'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Tên, nút edit và email
  Widget _buildUserInfo(User user, AuthProvider authProvider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Căn giữa Row
          children: [
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
              onPressed: () => _showEditProfileDialog(
                  context, authProvider), // Mở dialog khi nhấn
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
        Text(
          user.phoneNumber,
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
        shadows: const [
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
          // value
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
          const SizedBox(height: 8), 
          // label
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
        
        ClipOval(
          child: Image.network(
            'https://ichef.bbci.co.uk/ace/standard/976/cpsprodpb/153FD/production/_126973078_whatsubject.jpg.webp',
            width: 104,
            height: 104,
            fit: BoxFit.cover,
            
            // Xử lý khi đang tải ảnh
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                width: 30, 
                height: 30, 
                child: CircularProgressIndicator(strokeWidth: 2)
              );
            },
            
            // Xử lý khi lỗi link ảnh (hiện icon mặc định)
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 104,
                height: 104,
                color: Colors.grey[200],
                child: const Icon(Icons.person, color: Colors.grey),
              );
            },
          ),
        ),
      ],
    );
  }
}
