import 'package:equatable/equatable.dart';

enum DeviceType {
  binarySwitch,
  dimmableLight,
  thermostat,
}

abstract class Device extends Equatable {
  final int id;
  final String name;
  final String subtitle;
  final String iconAsset;
  final bool isOn;
  final DeviceType type;

  const Device({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.iconAsset,
    required this.isOn,
    required this.type,
  });

  // ===================== THAY ĐỔI Ở ĐÂY =====================
  factory Device.fromJson(Map<String, dynamic> json) {
    // Thêm dòng print này để kiểm tra dữ liệu JSON nhận được từ server
    print('[DEBUG] Parsing Device JSON: $json'); 

    final deviceTypeStr = json['device_type'] as String?;
    
    final deviceType = DeviceType.values.firstWhere(
      (e) => e.name == deviceTypeStr,
      // Nếu không có `device_type` trong JSON, nó sẽ mặc định là công tắc thường
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
  // ===================== KẾT THÚC THAY ĐỔI =====================

  Device copyWith({bool? isOn});

  @override
  List<Object?> get props => [id, name, subtitle, iconAsset, isOn, type];
}

class BinarySwitchDevice extends Device {
  const BinarySwitchDevice({
    required super.id,
    required super.name,
    required super.subtitle,
    required super.iconAsset,
    required super.isOn,
  }) : super(type: DeviceType.binarySwitch);

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
  Device copyWith({bool? isOn}) {
    return BinarySwitchDevice(
      id: id,
      name: name,
      subtitle: subtitle,
      iconAsset: iconAsset,
      isOn: isOn ?? this.isOn,
    );
  }
}

class DimmableLightDevice extends Device {
  final int brightness;

  const DimmableLightDevice({
    required super.id,
    required super.name,
    required super.subtitle,
    required super.iconAsset,
    required super.isOn,
    required this.brightness,
  }) : super(type: DeviceType.dimmableLight);

  factory DimmableLightDevice.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};
    return DimmableLightDevice(
      id: json['id'],
      name: json['name'],
      subtitle: json['subtitle'] ?? '',
      iconAsset: json['icon_asset'],
      isOn: json['is_on'],
      brightness: attributes['brightness'] as int? ?? 100,
    );
  }

  Device copyWith({bool? isOn, int? brightness}) {
    return DimmableLightDevice(
      id: id,
      name: name,
      subtitle: subtitle,
      iconAsset: iconAsset,
      isOn: isOn ?? this.isOn,
      brightness: brightness ?? this.brightness,
    );
  }

  @override
  List<Object?> get props => super.props..add(brightness);
}