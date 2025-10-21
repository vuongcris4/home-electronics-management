import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/device.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/device_remote_data_source.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource remote;
  DeviceRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, Device>> addDevice(
    String name, String subtitle, String iconAsset, int roomId,
  ) async {
    try {
      final dev = await remote.addDevice(name, subtitle, iconAsset, roomId);
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
}
