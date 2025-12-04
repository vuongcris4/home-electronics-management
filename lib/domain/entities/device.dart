import 'package:equatable/equatable.dart';

enum DeviceType {
  binarySwitch, // công tắc
  dimmableLight, // đèn độ sáng
}

abstract class Device extends Equatable {
  final int id;
  final String name; // tên
  final String subtitle; // mô tả
  final String iconAsset;
  final bool isOn; // on/off ?
  final DeviceType type; // công tắc hay đèn ?

  const Device({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.iconAsset,
    required this.isOn,
    required this.type,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    final deviceTypeStr = json['device_type'] as String?;

    // deviceType = DeviceType.binarySwitch hoặc DeviceType.dimmableLight
    final deviceType = DeviceType.values.firstWhere(
          (e) => e.name == deviceTypeStr,
      orElse: () => DeviceType.binarySwitch,
    );

    switch (deviceType) {
      case DeviceType.dimmableLight:
        return DimmableLightDevice.fromJson(json);
      case DeviceType.binarySwitch:
      default: 
        return BinarySwitchDevice.fromJson(json);
    }
  }

  Device copyWith({
    String? name,
    String? subtitle,
    bool? isOn,
  });

  @override
  List<Object?> get props => [id, name, subtitle, iconAsset, isOn, type];
}

class BinarySwitchDevice extends Device {
  // Constructor, gán cứng 'type' là binarySwitch
  const BinarySwitchDevice({
    required super.id,
    required super.name,
    required super.subtitle,
    required super.iconAsset,
    required super.isOn,
  }) : super(type: DeviceType.binarySwitch);

  // Factory constructor: Tạo BinarySwitchDevice từ JSON
  factory BinarySwitchDevice.fromJson(Map<String, dynamic> json) {
    return BinarySwitchDevice(
      id: json['id'],
      name: json['name'],
      subtitle: json['subtitle'] ?? '',
      iconAsset: json['icon_asset'],
      isOn: json['is_on'],
    );
  }

  @override
  Device copyWith({
    String? name,
    String? subtitle,
    bool? isOn,
  }) {
    return BinarySwitchDevice(
      id: id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      iconAsset: iconAsset,
      isOn: isOn ?? this.isOn,
    );
  }
}

class DimmableLightDevice extends Device {
  // Thuộc tính riêng: độ sáng (0-100)
  final int brightness;

  const DimmableLightDevice({
    required super.id,
    required super.name,
    required super.subtitle,
    required super.iconAsset,
    required super.isOn,
    required this.brightness,
  }) : super(type: DeviceType.dimmableLight);

  // Factory constructor: Tạo DimmableLightDevice từ JSON
  factory DimmableLightDevice.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};
    return DimmableLightDevice(
      id: json['id'],
      name: json['name'],
      subtitle: json['subtitle'] ?? '',
      iconAsset: json['icon_asset'],
      isOn: json['is_on'],
      // Lấy 'brightness' từ 'attributes', nếu không có thì mặc định là 100
      brightness: attributes['brightness'] as int? ?? 100,
    );
  }

  @override
  Device copyWith({
    String? name,
    String? subtitle,
    bool? isOn,
    int? brightness,
  }) {
    return DimmableLightDevice(
      id: id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      iconAsset: iconAsset,
      isOn: isOn ?? this.isOn,
      brightness: brightness ?? this.brightness, // Cập nhật cả brightness
    );
  }

  @override
  List<Object?> get props => super.props..add(brightness);
}
