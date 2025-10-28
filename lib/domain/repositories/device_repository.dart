// lib/domain/repositories/device_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/device.dart';

abstract class DeviceRepository {
  // thêm device
  Future<Either<Failure, Device>> addDevice(
    String name,
    String subtitle,
    String iconAsset,
    int roomId,
    DeviceType deviceType,
  );
  // xoá device
  Future<Either<Failure, Unit>> deleteDevice(int deviceId);

  // ===================== THÊM MỚI =====================
  Future<Either<Failure, Device>> updateDevice(
    int deviceId,
    String name,
    String subtitle,
  );
  // ===================== KẾT THÚC =====================
}