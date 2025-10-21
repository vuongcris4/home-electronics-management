import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/device.dart';

abstract class DeviceRepository {
  Future<Either<Failure, Device>> addDevice(String name, String subtitle, String iconAsset, int roomId,);
  Future<Either<Failure, Unit>> deleteDevice(int deviceId);
}
