import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/device_remote_data_source.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource remoteDataSource;
  // Bạn có thể thêm localDataSource ở đây để cache dữ liệu nếu cần

  DeviceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Room>>> getRooms() async {
    try {
      final rooms = await remoteDataSource.getRooms();
      return Right(rooms);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Room>> addRoom(String name) async {
    try {
      final newRoom = await remoteDataSource.addRoom(name);
      return Right(newRoom);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRoom(int roomId) async {
    try {
      await remoteDataSource.deleteRoom(roomId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Device>> addDevice(String name, String subtitle, String iconAsset, int roomId) async {
    try {
      final newDevice = await remoteDataSource.addDevice(name, subtitle, iconAsset, roomId);
      return Right(newDevice);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteDevice(int deviceId) async {
    try {
      await remoteDataSource.deleteDevice(deviceId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}