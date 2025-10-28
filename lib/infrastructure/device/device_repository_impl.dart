// lib/infrastructure/device/device_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/error/app_error.dart';
import '../../domain/entities/device.dart';
import '../../domain/repositories.dart';
import 'device_data_source.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource remote;
  DeviceRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, Device>> addDevice(
    String name,
    String subtitle,
    String iconAsset,
    int roomId,
    DeviceType deviceType,
  ) async {
    try {
      final dev =
          await remote.addDevice(name, subtitle, iconAsset, roomId, deviceType);
      return Right(dev);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteDevice(int deviceId) async {
    try {
      await remote.deleteDevice(deviceId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Device>> updateDevice(
      int deviceId, String name, String subtitle) async {
    try {
      final device = await remote.updateDevice(deviceId, name, subtitle);
      return Right(device);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}