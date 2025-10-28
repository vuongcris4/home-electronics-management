// lib/presentation/screens/control_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../domain/entities/device.dart';
import '../providers/home_provider.dart';

const Color kBackgroundColor = Color(0xFFF2F6FC);
const Color kPrimaryColor = Color(0xFF2666DE);
const Color kTextColorPrimary = Color(0xFF07123C);
const Color kTextColorSecondary = Color(0xFF6F7EA8);

class ControlScreen extends StatefulWidget {
  final Device device;

  const ControlScreen({super.key, required this.device});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        final device = provider.findDeviceById(widget.device.id) ?? widget.device;
      
        return Scaffold(
          backgroundColor: kBackgroundColor,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 140),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: device is DimmableLightDevice
                            ? _DimmableLightControls(device: device)
                            : _BinarySwitchControls(device: device),
                      ),
                    ),
                  ],
                ),
                _Header(device: device),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final Device device;
  const _Header({required this.device});

  void _showDeleteConfirmation(BuildContext context, HomeProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Device?'),
        content: Text(
            "Are you sure you want to delete '${device.name}'? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog first
              final success = await provider.removeDevice(device.id);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(const SnackBar(
                      content: Text('Device deleted successfully.'),
                      backgroundColor: Colors.green,
                    ));
                  Navigator.pop(context); // Go back to home screen
                } else {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text('Error: ${provider.errorMessage}'),
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

  // ===================== THÊM MỚI =====================
  void _showEditDeviceDialog(BuildContext context, HomeProvider provider) {
    final nameController = TextEditingController(text: device.name);
    final subtitleController = TextEditingController(text: device.subtitle);
    final formKey = GlobalKey<FormState>();

    showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Edit Device'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Device Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Name cannot be empty' : null,
                  ),
                  TextFormField(
                    controller: subtitleController,
                    decoration: const InputDecoration(labelText: 'Subtitle / Note'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final success = await provider.updateDeviceDetails(
                        device.id,
                        nameController.text,
                        subtitleController.text);

                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                    
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Update failed: ${provider.errorMessage}'),
                          backgroundColor: Colors.red));
                    }
                  }
                },
                child: const Text('Save'),
              )
            ],
          );
        });
  }
  // ===================== KẾT THÚC =====================

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: kTextColorPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              device.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kTextColorPrimary,
                fontSize: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: kPrimaryColor, size: 28),
                onPressed: () => _showEditDeviceDialog(context, provider),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                onPressed: () => _showDeleteConfirmation(context, provider),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ... Các widget _DimmableLightControls, _BinarySwitchControls, _PowerControlButton không thay đổi ...

class _DimmableLightControls extends StatelessWidget {
  final DimmableLightDevice device;
  const _DimmableLightControls({required this.device});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SleekCircularSlider(
          appearance: CircularSliderAppearance(
            customWidths: CustomSliderWidths(
              trackWidth: 12,
              progressBarWidth: 12,
              handlerSize: 8,
            ),
            customColors: CustomSliderColors(
              trackColor: const Color(0xFFECF1FD),
              dotColor: device.isOn ? kPrimaryColor : kTextColorSecondary,
              progressBarColors: device.isOn
                  ? [const Color(0xFF538FFB), const Color(0xFF2666DE)]
                  : [kTextColorSecondary, kTextColorSecondary],
            ),
            startAngle: 135,
            angleRange: 270,
            size: MediaQuery.of(context).size.width * 0.7,
          ),
          min: 0,
          max: 100,
          initialValue: device.brightness.toDouble(),
          onChangeEnd: (value) {
            provider.updateDeviceState(device.id, {'brightness': value.round()});
          },
          innerWidget: (double value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: '${value.round()}',
                        style: TextStyle(
                          color: device.isOn ? kTextColorPrimary : kTextColorSecondary,
                          fontSize: 30,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: '%',
                        style: TextStyle(
                          color: device.isOn
                              ? const Color(0xFFC9CBD8)
                              : kTextColorSecondary.withOpacity(0.5),
                          fontSize: 30,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Brightness',
                    style: TextStyle(
                      color: device.isOn ? kTextColorPrimary : kTextColorSecondary,
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        _PowerControlButton(device: device),
      ],
    );
  }
}

class _BinarySwitchControls extends StatelessWidget {
  final Device device;
  const _BinarySwitchControls({required this.device});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _PowerControlButton(device: device),
    );
  }
}

class _PowerControlButton extends StatelessWidget {
  final Device device;
  const _PowerControlButton({required this.device});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    final bool isOn = device.isOn;

    return GestureDetector(
      onTap: () {
        provider.toggleDeviceStatus(device.id, !isOn);
      },
      child: Container(
        width: 120,
        height: 146,
        decoration: BoxDecoration(
          color: isOn ? kPrimaryColor : kBackgroundColor,
          borderRadius: BorderRadius.circular(19),
          border: isOn ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.power_settings_new_rounded,
              color: isOn ? Colors.white : kTextColorSecondary,
              size: 30,
            ),
            const SizedBox(height: 20),
            Text(
              'Power',
              style: TextStyle(
                color: isOn ? const Color(0xFFD4E2FD) : kTextColorSecondary,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 5),
            Text(
              isOn ? 'ON' : 'OFF',
              style: TextStyle(
                color: isOn ? const Color(0xFFD4E2FD) : kTextColorSecondary,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}