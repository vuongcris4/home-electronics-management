// lib/presentation/widgets/device_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/device.dart';
import '../providers/home_provider.dart';

const Color kPrimaryColor = Color(0xFF2666DE);
const Color kTextColorPrimary = Color(0xFF07123C);
const Color kTextColorSecondary = Color(0xFF6F7EA8);
const Color kActiveCardColor = Color(0xFF2666DE);
const Color kInactiveCardColor = Colors.white;

class DeviceCard extends StatelessWidget {
  final Device device;
  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    final bool isActive = device.isOn;

    final Color cardColor = isActive ? kActiveCardColor : kInactiveCardColor;
    final Color titleColor = isActive ? Colors.white : kTextColorPrimary;
    final Color subtitleColor =
        isActive ? Colors.white.withOpacity(0.8) : kTextColorSecondary;
    final Color iconColor = isActive ? Colors.white : kPrimaryColor;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/control-device', arguments: device);
      },
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
                  device.iconAsset,
                  width: 32,
                  height: 32,
                  color: iconColor,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error, color: iconColor, size: 32);
                  },
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

  // ===================== MODIFIED METHOD =====================
  void _showDeleteDeviceConfirmation(BuildContext context, Device device) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Device?'),
        content: Text("Are you sure you want to delete '${device.name}'?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog first
              final provider = Provider.of<HomeProvider>(context, listen: false);
              final success = await provider.removeDevice(device.id);

              if (context.mounted) {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Device deleted successfully.'),
                      backgroundColor: Colors.green,
                    ));
                  } else {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error deleting device: ${provider.errorMessage}'),
                      backgroundColor: Colors.red,
                    ));
                  }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  // ===================== END OF MODIFIED METHOD =====================
}