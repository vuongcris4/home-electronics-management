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
    // Đây là một hàm khởi tạo factory (factory constructor). Nhiệm vụ của nó là nhận dữ liệu thô 
    //(thường là JSON trả về từ API) và chuyển đổi nó thành một đối tượng Device có cấu trúc rõ ràng.
    return Device(
      id: json['id'],
      name: json['name'],
      subtitle: json['subtitle'] ?? '',
      iconAsset: json['icon_asset'],
      isOn: json['is_on'],
    );
  }

  Device copyWith({bool? isOn}) {
    //Vì đối tượng Device là bất biến, bạn không thể cập nhật trực tiếp kiểu myDevice.isOn = true;. Vậy làm cách nào để cập nhật trạng thái? 
    //Bạn sẽ tạo ra một bản sao của nó với những giá trị đã được thay đổi. Đó chính xác là những gì phương thức copyWith làm.
    // Đây là một mẫu (pattern) cực kỳ phổ biến và quan trọng khi làm việc với các thư viện quản lý trạng thái như Provider hoặc BLoC.
    return Device(
      id: id,
      name: name,
      subtitle: subtitle,
      iconAsset: iconAsset,
      isOn: isOn ?? this.isOn,
    );
  }

  @override
  List<Object?> get props => [id, name, subtitle, iconAsset, isOn]; // Kế thừa danh sách thuộc tính
}