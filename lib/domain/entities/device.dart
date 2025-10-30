// lib/domain/entities/device.dart

// Import thư viện Equatable để giúp so sánh các đối tượng (VD: device1 == device2)
import 'package:equatable/equatable.dart';

// Định nghĩa các loại thiết bị mà ứng dụng hỗ trợ
enum DeviceType {
  binarySwitch,   // Công tắc bật/tắt
  dimmableLight,  // Đèn chỉnh được độ sáng
  thermostat,     // Bộ điều nhiệt (chưa dùng)
}

// Định nghĩa lớp 'abstract' (trừu tượng) Device
// Kế thừa Equatable để có thể so sánh các đối tượng
abstract class Device extends Equatable {
  // --- THUỘC TÍNH CHUNG ---
  final int id;                 // ID duy nhất
  final String name;            // Tên thiết bị
  final String subtitle;        // Mô tả phụ
  final String iconAsset;       // Đường dẫn đến file icon
  final bool isOn;              // Trạng thái bật/tắt
  final DeviceType type;        // Loại thiết bị (từ enum trên)

  // Constructor (hàm khởi tạo)
  const Device({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.iconAsset,
    required this.isOn,
    required this.type,
  });

  // Factory constructor: Dùng để tạo đối tượng Device từ dữ liệu JSON
  factory Device.fromJson(Map<String, dynamic> json) {
    // Dòng này để debug: In dữ liệu JSON nhận được ra console
    print('[DEBUG] Parsing Device JSON: $json');

    // Lấy giá trị của 'device_type' từ JSON (có thể là null)
    final deviceTypeStr = json['device_type'] as String?;

    // Chuyển đổi giá trị chuỗi (ví dụ: "dimmableLight") thành enum (DeviceType.dimmableLight)
    final deviceType = DeviceType.values.firstWhere(
          (e) => e.name == deviceTypeStr,
      // Nếu không tìm thấy (hoặc deviceTypeStr là null)
      // thì mặc định là 'binarySwitch'
      orElse: () => DeviceType.binarySwitch,
    );

    // Dùng switch...case để quyết định tạo lớp con (subclass) nào
    switch (deviceType) {
      case DeviceType.dimmableLight:
      // Nếu là đèn, gọi hàm .fromJson của DimmableLightDevice
        return DimmableLightDevice.fromJson(json);
      case DeviceType.binarySwitch:
      default: // Mặc định (hoặc là binarySwitch)
      // Gọi hàm .fromJson của BinarySwitchDevice
        return BinarySwitchDevice.fromJson(json);
    }
  }

  // ===================== THAY ĐỔI Ở ĐÂY =====================
  // Định nghĩa hàm 'copyWith' (sao chép) trừu tượng
  // Hàm này dùng để tạo 1 bản sao của đối tượng với một vài giá trị được thay đổi
  // Các lớp con BẮT BUỘC phải định nghĩa hàm này
  Device copyWith({
    String? name,
    String? subtitle,
    bool? isOn,
  });
  // ===================== KẾT THÚC THAY ĐỔI =====================

  @override
  // 'props' của Equatable: Liệt kê các thuộc tính sẽ được dùng để so...
  // ...so sánh 2 đối tượng Device
  List<Object?> get props => [id, name, subtitle, iconAsset, isOn, type];
}

// Lớp con: BinarySwitchDevice (Công tắc) - Kế thừa từ Device
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
      subtitle: json['subtitle'] ?? '', // Nếu subtitle là null, dùng chuỗi rỗng
      iconAsset: json['icon_asset'],
      isOn: json['is_on'],
    );
  }

  // ===================== THAY ĐỔI Ở ĐÂY =====================
  @override
  // Định nghĩa (implement) hàm copyWith cho BinarySwitchDevice
  Device copyWith({
    String? name,
    String? subtitle,
    bool? isOn,
  }) {
    // Trả về một đối tượng BinarySwitchDevice MỚI
    return BinarySwitchDevice(
      id: id,                               // Giữ nguyên id
      name: name ?? this.name,              // Nếu name mới là null, dùng name cũ (this.name)
      subtitle: subtitle ?? this.subtitle,  // Tương tự cho subtitle
      iconAsset: iconAsset,                 // Giữ nguyên iconAsset
      isOn: isOn ?? this.isOn,              // Tương tự cho isOn
    );
  }
// ===================== KẾT THÚC THAY ĐỔI =====================
}

// Lớp con: DimmableLightDevice (Đèn chỉnh độ sáng) - Kế thừa từ Device
class DimmableLightDevice extends Device {
  // Thuộc tính riêng: độ sáng (0-100)
  final int brightness;

  // Constructor, gán cứng 'type' là dimmableLight
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
    // Độ sáng thường nằm trong 1 object 'attributes' lồng bên trong
    // '?? {}' để tránh lỗi nếu 'attributes' là null
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

  // ===================== THAY ĐỔI Ở ĐÂY =====================
  @override
  // Định nghĩa hàm copyWith cho DimmableLightDevice
  // (Hàm này có thêm tham số 'brightness')
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
  // ===================== KẾT THÚC THAY ĐỔI =====================

  @override
  // 'props' của Equatable: Bổ sung 'brightness' vào danh sách so sánh
  List<Object?> get props => super.props..add(brightness);
}