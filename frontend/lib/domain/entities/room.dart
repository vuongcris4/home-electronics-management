import 'package:equatable/equatable.dart';
import 'device.dart';

// Kế thừa 'Equatable' để cho phép so sánh các đối tượng Room dựa trên giá trị của chúng (value equality) thay vì tham chiếu (reference equality).
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

  Room copyWith({String? name, List<Device>? devices}) {
    return Room(
      id: id,
      name: name ?? this.name,
      devices: devices ?? this.devices,
    );
  }

  // ghi đè props, so sánh value thay vì references
  @override
  List<Object?> get props => [id, name, devices];
}