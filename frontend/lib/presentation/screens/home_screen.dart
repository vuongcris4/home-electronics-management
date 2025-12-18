// lib/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/device_card.dart';
import '../widgets/home_header.dart';
import '../widgets/room_tabs.dart';
import '../widgets/home_bottom_nav_bar.dart';
import './alerts_screen.dart';
import './account.dart';

const Color kBackgroundColor = Color(0xFFF2F6FC);

// Nó cần là StatefulWidget vì nó quản lý trạng thái (_selectedIndex) của BottomNavBar
class SmartHomeScreen extends StatefulWidget {
  const SmartHomeScreen({super.key});

  @override
  State<SmartHomeScreen> createState() => _SmartHomeScreenState();
}

class _SmartHomeScreenState extends State<SmartHomeScreen> {
  int _selectedIndex = 1; 

  @override
  void initState() {
    super.initState();
    // initState được gọi 1 lần khi widget được tạo
    // Dùng addPostFrameCallback để gọi hàm *sau khi* frame đầu tiên được build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchRooms();
    });
  }

  static const List<Widget> _pages = <Widget>[
    AlertsScreen(),       // Index 0: Màn hình cảnh báo
    _HomeScreenContent(), // Index 1: Màn hình chính (nội dung home)
    ProfileScreen(),      // Index 2: Màn hình tài khoản
  ];

  // Rebuild lại homescreen khi nhấn nút Home navigation.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor, 
      // IndexedStack giữ cho tất cả các màn hình con trong _pages luôn "sống" nhưng chỉ hiển thị cái có index = _selectedIndex
      body: IndexedStack(
        index: _selectedIndex,  // rebuild lại để hiện hiện _selectedIndex lên trên cùng.
        children: _pages,
      ),
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: _selectedIndex, // Truyền giá trị _selectedIndex widget con để rebuild
        onTap: _onItemTapped, // Truyền hàm xuống widget con
      ),
    );
  }
}

/// Widget này chứa giao diện gốc của màn hình home (thiết bị, phòng...)
/// Tách ra thành widget riêng để 'SmartHomeScreen' chỉ làm nhiệm vụ điều hướng
class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          // Padding cho nội dung chính
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            // Column xếp các widget con theo chiều dọc
            child: Column(
              children: [
                const SizedBox(height: 130),       
                const RoomTabs(),                     // Hiển thị thanh chọn phòng
                const SizedBox(height: 20),           
                const Expanded(child: _DeviceGrid()), // Lưới thiết bị, Expanded lấp đầy
                const SizedBox(height: 20),           
                _AddDeviceButton(),                   // Nút "Add Device"
                const SizedBox(height: 20),           
              ],
            ),
          ),
          // HomeHeader nằm trong Stack, sẽ nổi lên trên cùng
          const HomeHeader(),
        ],
      ),
    );
  }
}

/// Widget hiển thị lưới (Grid) các 'DeviceCard'.
class _DeviceGrid extends StatelessWidget {
  const _DeviceGrid();
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        // == Xử lý các trạng thái khác nhau của Provider ==
        // 1. Nếu đang tải
        if (provider.state == HomeState.Loading) {
          return const Center(child: CircularProgressIndicator());
        }
        // 2. Nếu bị lỗi
        if (provider.state == HomeState.Error) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Lỗi: ${provider.errorMessage}.\nPhiên đăng nhập có thể đã hết hạn. Vui lòng thử khởi động lại ứng dụng.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        }
        // 3. Nếu chưa chọn phòng nào
        if (provider.selectedRoom == null) {
          return const Center(
              child: Text("Select a room or add a new one.",
                  style: TextStyle(color: Color(0xFF6F7EA8))));
        }
        // 4. Nếu phòng được chọn không có thiết bị nào
        if (provider.selectedRoom!.devices.isEmpty) {
          return const Center(
              child: Text(
                  "No devices in this room.\nPress 'Add Device' to start.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6F7EA8))));
        }
        // 5. Nếu mọi thứ OK, hiển thị GridView
        return GridView.builder(
          // Định nghĩa layout của Grid
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,      // 2 cột
            crossAxisSpacing: 20,   // Khoảng cách ngang
            mainAxisSpacing: 20,    // Khoảng cách dọc
            childAspectRatio: 1.0,  // Tỷ lệ (vuông)
          ),
          // Số lượng item bằng số thiết bị trong phòng đã chọn
          itemCount: provider.selectedRoom!.devices.length,
          // Hàm build cho mỗi item
          itemBuilder: (context, index) {
            final device = provider.selectedRoom!.devices[index];
            // Mỗi item là một DeviceCard
            return DeviceCard(device: device);
          },
        );
      },
    );
  }
}

/// Widget cho nút "Add Device".
class _AddDeviceButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    return ElevatedButton(
      onPressed: provider.selectedRoom == null
          ? null
          : () => Navigator.pushNamed(context, '/add-device'),  // Điều hướng khi nhấn
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2666DE),               // Màu nền nút
        minimumSize: const Size(260, 60),                       // Kích thước tối thiểu
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), // Bo góc
        elevation: 8, // Đổ bóng
        shadowColor: const Color(0xFF2666DE).withOpacity(0.4),
      ),
      child: const Text(
        'Add Device',
        style: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}