import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/device.dart'; // Thêm import
import '../entities/room.dart';

abstract class DeviceRepository {
  Future<Either<Failure, List<Room>>> getRooms();
  Future<Either<Failure, Room>> addRoom(String name);
  Future<Either<Failure, Unit>> deleteRoom(int roomId);
  Future<Either<Failure, Device>> addDevice(String name, String subtitle, String iconAsset, int roomId);
  Future<Either<Failure, Unit>> deleteDevice(int deviceId);
}