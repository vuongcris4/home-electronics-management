// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/device_card.dart';
import '../widgets/home_header.dart';
import '../widgets/room_tabs.dart';
import '../widgets/home_bottom_nav_bar.dart';
import './alerts_screen.dart'; // <-- 1. IMPORT ALERTS SCREEN
import './account.dart'; 

const Color kBackgroundColor = Color(0xFFF2F6FC);

class SmartHomeScreen extends StatefulWidget {
  const SmartHomeScreen({super.key});

  @override
  State<SmartHomeScreen> createState() => _SmartHomeScreenState();
}

class _SmartHomeScreenState extends State<SmartHomeScreen> {
  int _selectedIndex = 1; // <-- 2. ĐẶT MÀN HÌNH MẶC ĐỊNH LÀ HOME (INDEX 1)

  @override
  void initState() {
    super.initState();
    // Fetch initial room data when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchRooms();
    });
  }

  // <-- 3. CẬP NHẬT DANH SÁCH MÀN HÌNH
  static const List<Widget> _pages = <Widget>[
    AlertsScreen(),       // Index 0: Màn hình cảnh báo
    _HomeScreenContent(), // Index 1: Màn hình chính với các thiết bị
    ProfileScreen(),      // Index 2: Màn hình tài khoản
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      // Hiển thị màn hình được chọn từ danh sách _pages
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      // Sử dụng bottom navigation bar đã cập nhật
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

/// This widget contains the original UI for the home screen.
class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 130), // Space for the header
                const RoomTabs(),
                const SizedBox(height: 20),
                const Expanded(child: _DeviceGrid()),
                const SizedBox(height: 20),
                _AddDeviceButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const HomeHeader(),
        ],
      ),
    );
  }
}

/// The grid that displays device cards. (Unchanged)
class _DeviceGrid extends StatelessWidget {
  const _DeviceGrid();
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        if (provider.state == HomeState.Loading) {
          return const Center(child: CircularProgressIndicator());
        }
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
        if (provider.selectedRoom == null) {
          return const Center(
              child: Text("Select a room or add a new one.",
                  style: TextStyle(color: Color(0xFF6F7EA8))));
        }
        if (provider.selectedRoom!.devices.isEmpty) {
          return const Center(
              child: Text(
                  "No devices in this room.\nPress 'Add Device' to start.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6F7EA8))));
        }
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.0,
          ),
          itemCount: provider.selectedRoom!.devices.length,
          itemBuilder: (context, index) {
            final device = provider.selectedRoom!.devices[index];
            return DeviceCard(device: device);
          },
        );
      },
    );
  }
}

/// The "Add Device" button. (Unchanged)
class _AddDeviceButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    return ElevatedButton(
      onPressed: provider.selectedRoom == null
          ? null
          : () => Navigator.pushNamed(context, '/add-device'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2666DE),
        minimumSize: const Size(260, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 8,
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