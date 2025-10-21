// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/device_card.dart'; // Import widget mới
import '../widgets/home_header.dart'; // Import widget mới
import '../widgets/room_tabs.dart'; // Import widget mới
import '../widgets/home_bottom_nav_bar.dart'; // Import widget mới

// --- Bảng màu và Kiểu chữ ---
const Color kBackgroundColor = Color(0xFFF2F6FC);

class SmartHomeScreen extends StatefulWidget {
  const SmartHomeScreen({super.key});

  @override
  State<SmartHomeScreen> createState() => _SmartHomeScreenState();
}

class _SmartHomeScreenState extends State<SmartHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 130),
                  const RoomTabs(), // <-- Widget đã tách
                  const SizedBox(height: 20),
                  const Expanded(child: _DeviceGrid()), // Dùng Expanded
                  const SizedBox(height: 20),
                  _AddDeviceButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const HomeHeader(), // <-- Widget đã tách
          ],
        ),
      ),
      bottomNavigationBar: const HomeBottomNavBar(), // <-- Widget đã tách
    );
  }
}

// Widget này vẫn giữ lại vì nó phụ thuộc nhiều vào Consumer và logic của màn hình
class _DeviceGrid extends StatelessWidget {
  const _DeviceGrid();
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        if (provider.state == HomeState.Loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.selectedRoom == null) {
          return const Center(
              child: Text("Select a room or add a new one.",
                  style: TextStyle(color: Color(0xFF6F7EA8))));
        }
        if (provider.selectedRoom!.devices.isEmpty) {
          return const Center(
              child: Text("No devices in this room.\nPress 'Add Device' to start.",
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
            return DeviceCard(device: device); // <-- Widget đã tách
          },
        );
      },
    );
  }
}

// Nút và Dialog thêm thiết bị cũng giữ lại vì tính đặc thù
class _AddDeviceButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    return ElevatedButton(
      onPressed: provider.selectedRoom == null
          ? null
          : () => _showAddDeviceDialog(context),
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

  void _showAddDeviceDialog(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    final nameController = TextEditingController();
    final subtitleController = TextEditingController();
    const defaultIcon = 'assets/icons/lightbulb.png'; // Tạm thời

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add Device to ${provider.selectedRoom!.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Device Name"),
                autofocus: true),
            const SizedBox(height: 8),
            TextField(
                controller: subtitleController,
                decoration:
                    const InputDecoration(labelText: "Subtitle (e.g., brand)")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                provider.addNewDevice(
                  nameController.text.trim(),
                  subtitleController.text.trim(),
                  defaultIcon,
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}