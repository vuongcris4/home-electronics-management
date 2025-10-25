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

// [
//   {
//     "id": 1,
//     "name": "Phòng khách",
//     "devices": [
//       {
//         "id": 101,
//         "name": "Đèn chùm",
//         "subtitle": "Philips Hue",
//         "icon_asset": "assets/icons/chandelier.png",
//         "is_on": true
//       },
//       {
//         "id": 102,
//         "name": "Smart TV",
//         "subtitle": "Samsung 55 inch",
//         "icon_asset": "assets/icons/tv.png",
//         "is_on": false
//       }
//     ]
//   },
//   {
//     "id": 2,
//     "name": "Phòng ngủ",
//     "devices": [
//       {
//         "id": 201,
//         "name": "Máy lạnh",
//         "subtitle": "Daikin Inverter",
//         "icon_asset": "assets/icons/air_conditioner.png",
//         "is_on": true
//       },
//       {
//         "id": 202,
//         "name": "Đèn ngủ",
//         "subtitle": null,
//         "icon_asset": "assets/icons/lamp.png",
//         "is_on": false
//       }
//     ]
//   },
//   {
//     "id": 3,
//     "name": "Nhà bếp",
//     "devices": []
//   }
// ]