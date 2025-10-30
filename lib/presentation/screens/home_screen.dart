// lib/presentation/screens/home_screen.dart

// Import thư viện Material UI cơ bản của Flutter
import 'package:flutter/material.dart';
// Import Provider để quản lý state
import 'package:provider/provider.dart';
// Import HomeProvider (quản lý state cho rooms, devices)
import '../providers/home_provider.dart';
// Import widget 'DeviceCard' (hiển thị 1 ô thiết bị)
import '../widgets/device_card.dart';
// Import widget 'HomeHeader' (hiwwển thị tiêu đề "Control Home")
import '../widgets/home_header.dart';
// Import widget 'RoomTabs' (thanh chọn phòng)
import '../widgets/room_tabs.dart';
// Import widget 'HomeBottomNavBar' (thanh điều hướng dưới cùng)
import '../widgets/home_bottom_nav_bar.dart';
// Import màn hình 'AlertsScreen'
import './alerts_screen.dart'; // <-- 1. IMPORT ALERTS SCREEN
// Import màn hình 'ProfileScreen' (do file tên là account.dart)
import './account.dart';

// Hằng số định nghĩa màu nền chính cho màn hình
const Color kBackgroundColor = Color(0xFFF2F6FC);

// Widget chính cho màn hình Home, là một StatefulWidget
// Nó cần là StatefulWidget vì nó quản lý trạng thái (_selectedIndex) của BottomNavBar
class SmartHomeScreen extends StatefulWidget {
  const SmartHomeScreen({super.key});

  @override
  State<SmartHomeScreen> createState() => _SmartHomeScreenState();
}

// Class chứa State (trạng thái) của SmartHomeScreen
class _SmartHomeScreenState extends State<SmartHomeScreen> {
  // Biến lưu trữ index (vị trí) của tab đang được chọn ở BottomNavBar
  int _selectedIndex = 1; // <-- 2. ĐẶT MÀN HÌNH MẶC ĐỊNH LÀ HOME (INDEX 1)

  @override
  void initState() {
    super.initState();
    // initState được gọi 1 lần khi widget được tạo
    // Dùng addPostFrameCallback để gọi hàm *sau khi* frame đầu tiên được build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Lấy HomeProvider (listen: false vì chỉ muốn gọi hàm) và fetch dữ liệu phòng
      Provider.of<HomeProvider>(context, listen: false).fetchRooms();
    });
  }

  // <-- 3. CẬP NHẬT DANH SÁCH MÀN HÌNH
  // Danh sách các widget (màn hình) tương ứng với các tab của BottomNavBar
  static const List<Widget> _pages = <Widget>[
    AlertsScreen(),       // Index 0: Màn hình cảnh báo
    _HomeScreenContent(), // Index 1: Màn hình chính (nội dung home)
    ProfileScreen(),      // Index 2: Màn hình tài khoản
  ];

  // Hàm được gọi khi người dùng nhấn vào một item trên BottomNavBar
  void _onItemTapped(int index) {
    // Cập nhật lại state để thay đổi màn hình
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold là khung sườn cho màn hình
    return Scaffold(
      backgroundColor: kBackgroundColor, // Đặt màu nền
      // Body của Scaffold sẽ hiển thị màn hình (page) dựa trên _selectedIndex
      body: IndexedStack(
        // IndexedStack giữ cho tất cả các màn hình con trong _pages luôn "sống"
        // nhưng chỉ hiển thị cái có index = _selectedIndex
        index: _selectedIndex,
        children: _pages,
      ),
      // Thanh điều hướng dưới cùng
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: _selectedIndex, // Truyền index hiện tại
        onTap: _onItemTapped, // Truyền hàm xử lý khi nhấn
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
    // SafeArea đảm bảo nội dung không bị che bởi tai thỏ, thanh trạng thái...
    return SafeArea(
      bottom: false, // Không áp dụng SafeArea cho cạnh dưới
      // Stack cho phép các widget con xếp chồng lên nhau
      // (Dùng để HomeHeader nổi lên trên)
      child: Stack(
        children: [
          // Padding cho nội dung chính
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            // Column xếp các widget con theo chiều dọc
            child: Column(
              children: [
                const SizedBox(height: 130),          // Tạo khoảng trống cho HomeHeader
                const RoomTabs(),                     // Hiển thị thanh chọn phòng
                const SizedBox(height: 20),           // Khoảng cách
                const Expanded(child: _DeviceGrid()), // Lưới thiết bị, Expanded lấp đầy
                const SizedBox(height: 20),           // Khoảng cách
                _AddDeviceButton(),                   // Nút "Add Device"
                const SizedBox(height: 20),           // Khoảng cách
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
    // Consumer "lắng nghe" thay đổi từ HomeProvider
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
    // Dùng context.watch để lấy Provider (build lại khi provider thay đổi)
    final provider = context.watch<HomeProvider>();
    return ElevatedButton(
      // Nút bị vô hiệu hóa (onPressed: null) nếu chưa chọn phòng
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