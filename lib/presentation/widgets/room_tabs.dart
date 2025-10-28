// lib/presentation/widgets/room_tabs.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/room.dart';
import '../providers/home_provider.dart';

const Color kPrimaryColor = Color(0xFF2666DE);
const Color kTextColorSecondary = Color(0xFF6F7EA8);

class RoomTabs extends StatelessWidget {
  const RoomTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        if (provider.state == HomeState.Loading && provider.rooms.isEmpty) {
          return const SizedBox(
              height: 50, child: Center(child: CircularProgressIndicator()));
        }
        return Row(
          children: [
            IconButton(
              icon: Image.asset('assets/icons/minus.png',
                  width: 24,
                  height: 24,
                  color: provider.selectedRoom != null ? null : Colors.grey),
              onPressed: provider.selectedRoom == null
                  ? null
                  : () => _showDeleteRoomConfirmation(context),
            ),
            Expanded(
              child: provider.rooms.isEmpty
                  ? const Center(child: Text("No rooms yet. Tap '+' to add."))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(provider.rooms.length, (index) {
                          final room = provider.rooms[index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: GestureDetector(
                              onTap: () => provider.selectRoom(index),
                              // ===================== THÊM MỚI =====================
                              onLongPress: () =>
                                  _showEditRoomDialog(context, room),
                              // ===================== KẾT THÚC =====================
                              child: _RoomTabItem(
                                text: room.name,
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
              onPressed: () => Navigator.pushNamed(context, '/add-room'),
            ),
          ],
        );
      },
    );
  }

  // ===================== CẬP NHẬT =====================
  void _showDeleteRoomConfirmation(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context, listen: false);

    // KIỂM TRA NẾU PHÒNG CÓ THIẾT BỊ
    if (provider.selectedRoom!.devices.isNotEmpty) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Cannot Delete Room'),
          content: const Text(
              'This room contains devices. Please remove all devices from this room before deleting it.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return; // Dừng hàm tại đây
    }

    // Nếu không có thiết bị, hiển thị dialog xác nhận xóa
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Room?'),
        content: Text(
            "Are you sure you want to delete '${provider.selectedRoom!.name}'? This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
               Navigator.pop(dialogContext); // Đóng dialog trước
               await provider.removeSelectedRoom();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  // ===================== KẾT THÚC CẬP NHẬT =====================

  // ===================== THÊM MỚI =====================
  void _showEditRoomDialog(BuildContext context, Room room) {
    final nameController = TextEditingController(text: room.name);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Room Name'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Room Name'),
            validator: (value) =>
                value!.isEmpty ? 'Name cannot be empty' : null,
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
                final provider = Provider.of<HomeProvider>(context, listen: false);
                await provider.updateRoomName(room.id, nameController.text);
                if (dialogContext.mounted) {
                   Navigator.pop(dialogContext);
                }
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
  // ===================== KẾT THÚC =====================
}

class _RoomTabItem extends StatelessWidget {
  final String text;
  final bool isActive;
  const _RoomTabItem({required this.text, this.isActive = false});

  @override
  Widget build(BuildContext context) {
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