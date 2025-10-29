import 'package:equatable/equatable.dart';
import 'device.dart';

// Đây là một 'Entity' (Thực thể) trong Domain Layer (Lớp 2).
// Nó định nghĩa cấu trúc dữ liệu cốt lõi cho một 'Phòng' trong ứng dụng.
// Kế thừa 'Equatable' để cho phép so sánh các đối tượng Room
// dựa trên giá trị của chúng (value equality) thay vì tham chiếu (reference equality).
class Room extends Equatable {
  final int id;
  final String name;
  final List<Device> devices; // Một phòng chứa một danh sách các thiết bị

  const Room({
    required this.id,
    required this.name,
    required this.devices,
  });

  // Factory constructor này dùng để 'deserialize' - tức là
  // chuyển đổi một đối tượng Map (thường là JSON nhận từ API)
  // thành một đối tượng Room.
  factory Room.fromJson(Map<String, dynamic> json) {
    // Lấy danh sách thô (List<dynamic>) từ JSON.
    var deviceList = json['devices'] as List;
    
    // Chuyển đổi (map) từng phần tử trong danh sách thô
    // thành một đối tượng 'Device' bằng cách gọi Device.fromJson().
    List<Device> devices = deviceList.map((i) => Device.fromJson(i)).toList();

    // Trả về một đối tượng Room mới với dữ liệu đã được phân tích.
    return Room(
      id: json['id'],
      name: json['name'],
      devices: devices, // Gán danh sách thiết bị đã được chuyển đổi
    );
  }

  // ===================== Hàm 'copyWith' =====================
  // Hàm 'copyWith' rất quan trọng khi làm việc với 'immutable objects'
  // (các đối tượng có thuộc tính 'final').
  // Nó tạo ra một bản 'sao chép' (copy) của đối tượng Room hiện tại,
  // nhưng cho phép 'ghi đè' các giá trị cụ thể nếu chúng được cung cấp.
  Room copyWith({String? name, List<Device>? devices}) {
    return Room(
      id: id, // ID luôn được giữ nguyên từ đối tượng gốc
      // Nếu 'name' mới được cung cấp (không null), dùng nó.
      // Nếu không (null), dùng giá trị 'name' của đối tượng hiện tại (this.name).
      name: name ?? this.name,
      // Tương tự, nếu 'devices' mới được cung cấp, dùng nó.
      // Nếu không, dùng danh sách 'devices' của đối tượng hiện tại.
      devices: devices ?? this.devices,
    );
  }
  // ===================== END OF 'copyWith' =====================


  // Ghi đè phương thức 'props' từ Equatable.
  // Đây là nơi bạn định nghĩa những thuộc tính nào sẽ được sử dụng
  // để so sánh hai đối tượng Room.
  // Hai đối tượng Room sẽ được coi là 'bằng nhau' (==) nếu 'id', 'name',
  // và 'devices' của chúng giống hệt nhau.
  @override
  List<Object?> get props => [id, name, devices];
}