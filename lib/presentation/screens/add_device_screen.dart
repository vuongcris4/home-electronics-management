// lib/presentation/screens/add_device_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/device.dart'; // <-- ADDED
import '../providers/home_provider.dart';

// --- Các hằng số màu sắc và style cho nhất quán ---
const Color kPrimaryColor = Color(0xFF2666DE);
const Color kTextColorSecondary = Color(0xFF6F7EA8);
const Color kBorderColor = Color(0xFFCFCFCF);
const Color kLabelColor = Color(0xFF13304A);

// --- Dữ liệu giả lập cho các icon ---
class IconInfo {
  final IconData iconData;
  final String label;
  final String assetName; // Tên file trong assets/icons/
  IconInfo(
      {required this.iconData, required this.label, required this.assetName});
}

final List<IconInfo> availableIcons = [
  IconInfo(
      iconData: Icons.lightbulb_outline,
      label: 'Light',
      assetName: 'lightbulb.png'),
  IconInfo(
      iconData: Icons.air, label: 'Cooler', assetName: 'air_conditioner.png'),
  IconInfo(iconData: Icons.tv, label: 'TV', assetName: 'tv.png'),
  IconInfo(iconData: Icons.wifi, label: 'Wifi', assetName: 'wifi.png'),
  IconInfo(
      iconData: Icons.music_note, label: 'Music', assetName: 'speaker.png'),
  IconInfo(iconData: Icons.power, label: 'Other', assetName: 'power.png'),
];

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedIconAsset = availableIcons.first.assetName;

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addDevice() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Device name cannot be empty.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final provider = Provider.of<HomeProvider>(context, listen: false);

    // ================== CHANGE IS HERE ==================
    // Determine the device type based on the selected icon
    final deviceType = _selectedIconAsset == 'lightbulb.png'
        ? DeviceType.dimmableLight
        : DeviceType.binarySwitch;

    final success = await provider.addNewDevice(
      _nameController.text.trim(),
      _noteController.text.trim(),
      'assets/icons/$_selectedIconAsset', // Create asset path
      deviceType, // Pass the determined device type
    );
    // ================== END OF CHANGE ==================

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add device: ${provider.errorMessage}'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<HomeProvider>().isLoadingAction;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add Device',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF404040),
                    fontSize: 32,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 60),
                _CustomTextField(
                  label: 'Name Device',
                  hint: 'Name Device',
                  controller: _nameController,
                ),
                const SizedBox(height: 30),
                _CustomTextField(
                  label: 'Note',
                  hint: 'Note (e.g. brand, location)',
                  controller: _noteController,
                ),
                const SizedBox(height: 60),
                const Text(
                  'Select Icon',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: availableIcons.map((iconInfo) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: _IconSelectionButton(
                          icon: iconInfo.iconData,
                          label: iconInfo.label,
                          isSelected: _selectedIconAsset == iconInfo.assetName,
                          onTap: () {
                            setState(() {
                              _selectedIconAsset = iconInfo.assetName;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 80),
                ElevatedButton(
                  onPressed: isLoading ? null : _addDevice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 19),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _CustomTextField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: kBorderColor),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 19),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: const BorderSide(color: kBorderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
            ),
          ),
        ),
        Positioned(
          left: 40,
          top: -10,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label,
              style: const TextStyle(
                color: kLabelColor,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IconSelectionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _IconSelectionButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 67,
            height: 67,
            decoration: BoxDecoration(
                color: isSelected ? kPrimaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        const BoxShadow(
                          color: Color(0x5B3880F6),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      ]
                    : [],
                border: isSelected
                    ? null
                    : Border.all(color: kBorderColor.withOpacity(0.5))),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : kTextColorSecondary,
              size: 30,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? kPrimaryColor : kTextColorSecondary,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
}