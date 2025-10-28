// lib/presentation/screens/account.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/user.dart';
import '../../injection_container.dart';
import '../providers/auth_provider.dart';
import '../providers/home_provider.dart';

// ==========================================================
// CONSTANTS
// ==========================================================
const Color kBackgroundColor = Color(0xFFF2F6FC);
const Color kPrimaryColor = Color(0xFF2666DE);
const Color kTextColor = Color(0xFF6F7EA8);
const Color kCardColor = Colors.white;

// ==========================================================
// MAIN WIDGET: ProfileScreen
// ==========================================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Lấy dữ liệu profile khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Chỉ fetch nếu chưa có dữ liệu user
      if (authProvider.user == null) {
        authProvider.fetchUserProfile();
      }
    });
  }

  /// Xử lý đăng xuất
  Future<void> _logout(BuildContext context) async {
    final storage = getIt<FlutterSecureStorage>();
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');

    if (context.mounted) {
      // Xóa dữ liệu state trong các provider
      Provider.of<AuthProvider>(context, listen: false).clearUserData();
      await Provider.of<HomeProvider>(context, listen: false).clearLocalData();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  // ===================== THÊM MỚI =====================
  /// Hiển thị dialog để sửa thông tin profile
  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final nameController = TextEditingController(text: authProvider.user?.name);
    final phoneController =
        TextEditingController(text: authProvider.user?.phoneNumber);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Name cannot be empty' : null,
                ),
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
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final success = await authProvider.updateProfile(
                    name: nameController.text,
                    phoneNumber: phoneController.text,
                  );
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
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
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        // Tính toán số liệu từ HomeProvider
        final totalDevices = homeProvider.rooms
            .fold<int>(0, (sum, room) => sum + room.devices.length);
        final devicesOn = homeProvider.rooms.fold<int>(
            0,
            (sum, room) =>
                sum + room.devices.where((d) => d.isOn).length);
        final devicesOff = totalDevices - devicesOn;

        return Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;
            final profileState = authProvider.profileState;

            return Scaffold(
              backgroundColor: kBackgroundColor,
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // HEADER: Logout Button
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
                              icon: Image.asset('assets/icons/exit.png',
                                  color: kPrimaryColor),
                              onPressed: () => _logout(context),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // AVATAR
                    const SizedBox(height: 20),
                    _buildAvatar(),
                    const SizedBox(height: 15),

                    // Tên và Email
                    if (profileState == ViewState.Loading)
                      const CircularProgressIndicator(),
                    if (profileState == ViewState.Success && user != null)
                      _buildUserInfo(user, authProvider),
                    if (profileState == ViewState.Error)
                      const Text("Failed to load profile",
                          style: TextStyle(color: Colors.red)),

                    const SizedBox(height: 30),

                    // ===================== THAY ĐỔI Ở ĐÂY =====================
                    // INFO CARDS GRID
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
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

  // Widget hiển thị thông tin người dùng và nút edit
  Widget _buildUserInfo(User user, AuthProvider authProvider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: kTextColor),
              onPressed: () => _showEditProfileDialog(context, authProvider),
            )
          ],
        ),
        const SizedBox(height: 4),
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

  // Các helper widget không đổi
  Widget _buildInfoCard(String value, String label) {
    return Container(
      decoration: ShapeDecoration(
        color: kCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(19.02),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
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
        // Placeholder for avatar image
      ],
    );
  }
}