// lib/domain/usecases/device_usecases.dart

// Import thư viện 'dartz' để sử dụng 'Either' (cho xử lý lỗi) và 'Unit' (cho void)
import 'package:dartz/dartz.dart';
// Import 'equatable' để giúp so sánh các đối tượng Params
import 'package:equatable/equatable.dart';

// Import các định nghĩa lỗi chung của ứng dụng (ví dụ: Failure)
import '../../core/error/app_error.dart';
// Import 'UseCase' (lớp base trừu tượng cho các Usecase)
import '../../core/usecase/usecase.dart';
// Import định nghĩa (entity) của Device
import '../entities/device.dart';
// Import 'DeviceRepository' (lớp trừu tượng định nghĩa các hàm của repository)
import '../repositories.dart';

// --- Add Device (Thêm thiết bị) ---

// Định nghĩa Usecase để thêm một thiết bị
// Implement (triển khai) lớp 'UseCase' chung
// - 'Device': Kiểu dữ liệu trả về khi thành công
// - 'AddDeviceParams': Kiểu dữ liệu tham số đầu vào
class AddDeviceUseCase implements UseCase<Device, AddDeviceParams> {
  // Usecase này phụ thuộc vào một 'DeviceRepository'
  final DeviceRepository repository;
  // Constructor: Yêu cầu 'repository' phải được cung cấp (dependency injection)
  AddDeviceUseCase(this.repository);

  @override
  // Hàm 'call' là hàm chính được thực thi khi gọi Usecase
  // Nó trả về 'Either<Failure, Device>' (Hoặc Lỗi, Hoặc Thiết bị)
  Future<Either<Failure, Device>> call(AddDeviceParams params) async {
    // Gọi hàm 'addDevice' từ repository và truyền các tham số
    return await repository.addDevice(params.name, params.subtitle,
        params.iconAsset, params.roomId, params.deviceType);
  }
}

// Lớp chứa các tham số (parameters) cho AddDeviceUseCase
// Kế thừa 'Equatable' để dễ dàng so sánh, testing
class AddDeviceParams extends Equatable {
  final String name;
  final String subtitle;
  final String iconAsset;
  final int roomId; // ID của phòng chứa thiết bị
  final DeviceType deviceType; // Loại thiết bị

  // Constructor
  const AddDeviceParams({
    required this.name,
    required this.subtitle,
    required this.iconAsset,
    required this.roomId,
    required this.deviceType,
  });

  @override
  // Liệt kê các thuộc tính để 'Equatable' so sánh
  List<Object> get props => [name, subtitle, iconAsset, roomId, deviceType];
}


/// --- Delete Device (Xóa thiết bị) ---

// Định nghĩa Usecase để xóa một thiết bị
// - 'Unit': (từ dartz) Đại diện cho 'void', nghĩa là thành công nhưng không trả về data
// - 'DeleteDeviceParams': Tham số đầu vào
class DeleteDeviceUseCase implements UseCase<Unit, DeleteDeviceParams> {
  final DeviceRepository repository;
  DeleteDeviceUseCase(this.repository);

  @override
  // Hàm 'call' chính
  Future<Either<Failure, Unit>> call(DeleteDeviceParams params) async {
    // Gọi hàm 'deleteDevice' từ repository
    return await repository.deleteDevice(params.deviceId);
  }
}

// Lớp chứa tham số cho DeleteDeviceUseCase
class DeleteDeviceParams extends Equatable {
  final int deviceId; // Chỉ cần ID của thiết bị để xóa
  const DeleteDeviceParams({required this.deviceId});

  @override
  List<Object> get props => [deviceId];
}

// --- Update Device (Cập nhật thiết bị) ---

// Định nghĩa Usecase để cập nhật thông tin thiết bị (tên, subtitle)
// - 'Device': Trả về thiết bị đã được cập nhật khi thành công
// - 'UpdateDeviceParams': Tham số đầu vào
class UpdateDeviceUseCase implements UseCase<Device, UpdateDeviceParams> {
  final DeviceRepository repository;
  UpdateDeviceUseCase(this.repository);

  @override
  // Hàm 'call' chính
  Future<Either<Failure, Device>> call(UpdateDeviceParams params) async {
    // Gọi hàm 'updateDevice' từ repository
    return await repository.updateDevice(
        params.id, params.name, params.subtitle);
  }
}

// Lớp chứa tham số cho UpdateDeviceUseCase
class UpdateDeviceParams extends Equatable {
  final int id; // ID của thiết bị cần update
  final String name; // Tên mới
  final String subtitle; // Subtitle mới

  const UpdateDeviceParams({
    required this.id,
    required this.name,
    required this.subtitle,
  });

  @override
  List<Object> get props => [id, name, subtitle];
}