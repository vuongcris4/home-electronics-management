import 'package:equatable/equatable.dart';
import 'device.dart';

class Room extends Equatable {
  final int id;
  final String name;
  final List<Device> devices;

  const Room({
    required this.id,
    required this.name,
    required this.devices,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    var deviceList = json['devices'] as List;
    List<Device> devices = deviceList.map((i) => Device.fromJson(i)).toList();

    return Room(
      id: json['id'],
      name: json['name'],
      devices: devices,
    );
  }

  @override
  List<Object?> get props => [id, name, devices];
}