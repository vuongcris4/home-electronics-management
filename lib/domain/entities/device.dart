import 'package:equatable/equatable.dart';

class Device extends Equatable {
  final int id;
  final String name;
  final String subtitle;
  final String iconAsset;
  final bool isOn;

  const Device({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.iconAsset,
    required this.isOn,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      subtitle: json['subtitle'] ?? '',
      iconAsset: json['icon_asset'],
      isOn: json['is_on'],
    );
  }

  Device copyWith({bool? isOn}) {
    return Device(
      id: id,
      name: name,
      subtitle: subtitle,
      iconAsset: iconAsset,
      isOn: isOn ?? this.isOn,
    );
  }

  @override
  List<Object?> get props => [id, name, subtitle, iconAsset, isOn];
}