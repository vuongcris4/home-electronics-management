// lib/presentation/widgets/room_tabs.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
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
              onPressed: () => Navigator.pushNamed(context, '/add-room'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteRoomConfirmation(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Room?'),
        content: Text(
            "Are you sure you want to delete '${provider.selectedRoom!.name}' and all its devices? This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
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