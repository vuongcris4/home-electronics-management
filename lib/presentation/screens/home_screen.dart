// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/device.dart';
import '../providers/home_provider.dart';


// --- Bảng màu và Kiểu chữ ---
const Color kBackgroundColor = Color(0xFFF2F6FC);
const Color kPrimaryColor = Color(0xFF2666DE);
const Color kTextColorPrimary = Color(0xFF07123C);
const Color kTextColorSecondary = Color(0xFF6F7EA8);
const Color kActiveCardColor = Color(0xFF2666DE);
const Color kInactiveCardColor = Colors.white;

// --- Màn hình chính (StatefulWidget) ---
class SmartHomeScreen extends StatefulWidget {
  const SmartHomeScreen({super.key});

  @override
  State<SmartHomeScreen> createState() => _SmartHomeScreenState();
}

class _SmartHomeScreenState extends State<SmartHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Đảm bảo rằng context đã sẵn sàng trước khi gọi provider
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
                  _RoomTabs(),
                  const SizedBox(height: 20),
                  Expanded(child: _DeviceGrid()), // Dùng Expanded để GridView có thể cuộn
                  const SizedBox(height: 20),
                  _AddDeviceButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const _Header(), // Header không đổi
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(), // Bottom Nav không đổi
    );
  }
}

// --- Các Widget con ---

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    // ... Giữ nguyên code của bạn ...
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'October 21, 2025',
                style: TextStyle(color: kTextColorSecondary, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'Smart home',
                style: TextStyle(
                  color: kTextColorPrimary,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Image.asset(
                'assets/icons/exit.png',
                width: 22,
                height: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        if (provider.state == HomeState.Loading && provider.rooms.isEmpty) {
          return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()));
        }
        return Row(
          children: [
            IconButton(
              icon: Image.asset('assets/icons/minus.png', width: 24, height: 24, color: provider.selectedRoom != null ? null : Colors.grey),
              onPressed: provider.selectedRoom == null ? null : () => _showDeleteRoomConfirmation(context),
            ),
            Expanded(
              child: provider.rooms.isEmpty
                  ? const Center(child: Text("No rooms yet. Tap '+' to add."))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(provider.rooms.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: GestureDetector(
                              onTap: () => provider.selectRoom(index),
                              child: _RoomTabItem(
                                text: provider.rooms[index].name,
                                isActive: provider.selectedRoomIndex == index,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
            ),
            IconButton(
              icon: Image.asset('assets/icons/add.png', width: 24, height: 24),
              onPressed: () => _showAddRoomDialog(context),
            ),
          ],
        );
      },
    );
  }

  void _showAddRoomDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Room'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "E.g., Living Room"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Provider.of<HomeProvider>(context, listen: false).addNewRoom(controller.text.trim());
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteRoomConfirmation(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context, listen: false);
     showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Room?'),
        content: Text("Are you sure you want to delete '${provider.selectedRoom!.name}' and all its devices? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
                provider.removeSelectedRoom();
                Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _RoomTabItem extends StatelessWidget {
  final String text;
  final bool isActive;
  const _RoomTabItem({required this.text, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    // ... Giữ nguyên code của bạn ...
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            color: isActive ? kPrimaryColor : kTextColorSecondary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (isActive)
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
      ],
    );
  }
}

class _DeviceGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        if (provider.state == HomeState.Loading) {
            return const Center(child: CircularProgressIndicator());
        }
        if (provider.selectedRoom == null) {
          return const Center(child: Text("Select a room or add a new one.", style: TextStyle(color: kTextColorSecondary)));
        }
        if (provider.selectedRoom!.devices.isEmpty) {
          return const Center(child: Text("No devices in this room.\nPress 'Add Device' to start.", textAlign: TextAlign.center, style: TextStyle(color: kTextColorSecondary)));
        }
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.0, // Đảm bảo card là hình vuông
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

class DeviceCard extends StatelessWidget {
  final Device device;
  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    final bool isActive = device.isOn;
    
    final Color cardColor = isActive ? kActiveCardColor : kInactiveCardColor;
    final Color titleColor = isActive ? Colors.white : kTextColorPrimary;
    final Color subtitleColor = isActive ? Colors.white.withOpacity(0.8) : kTextColorSecondary;
    final Color iconColor = isActive ? Colors.white : kPrimaryColor;

    return GestureDetector(
      onLongPress: () => _showDeleteDeviceConfirmation(context, device),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/icons/lightbulb.png', // Thay thế bằng device.iconAsset khi có
                  width: 32,
                  height: 32,
                  color: iconColor,
                ),
                Transform.scale(
                  scale: 0.9,
                  alignment: Alignment.topRight,
                  child: Switch(
                    value: isActive,
                    onChanged: (value) {
                      provider.toggleDeviceStatus(device.id, value);
                    },
                    activeColor: Colors.white,
                    activeTrackColor: Colors.lightBlue.shade200,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  device.subtitle,
                  style: TextStyle(color: subtitleColor, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDeviceConfirmation(BuildContext context, Device device) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Device?'),
        content: Text("Are you sure you want to delete '${device.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Provider.of<HomeProvider>(context, listen: false).removeDevice(device.id);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _AddDeviceButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    return ElevatedButton(
      onPressed: provider.selectedRoom == null ? null : () => _showAddDeviceDialog(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        minimumSize: const Size(260, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 8,
        shadowColor: kPrimaryColor.withOpacity(0.4),
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
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Device Name"), autofocus: true),
            const SizedBox(height: 8),
            TextField(controller: subtitleController, decoration: const InputDecoration(labelText: "Subtitle (e.g., brand)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
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

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();
  @override
  Widget build(BuildContext context) {
    // ... Giữ nguyên code của bạn ...
    return Container(
      height: 75,
      decoration: const BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset('assets/icons/document.png', width: 30, height: 30, color: Colors.white),
          Image.asset('assets/icons/home.png', width: 30, height: 30, color: Colors.white),
          Image.asset('assets/icons/profile.png', width: 30, height: 30, color: Colors.white),
        ],
      ),
    );
  }
}