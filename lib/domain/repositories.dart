// lib/domain/repositories.dart
import 'package:dartz/dartz.dart';

import '../core/error/app_error.dart';
import 'entities/device.dart';
import 'entities/room.dart';
import 'entities/user.dart';

//--- Auth Repository ---
abstract class AuthRepository {
  Future<Either<Failure, Unit>> login(String email, String password);
  Future<Either<Failure, Unit>> register({
    required String name,
    required String email,
    required String password,
    required String password2,
    required String phoneNumber,
  });
  Future<Either<Failure, User>> getUserProfile();
  Future<Either<Failure, User>> updateUserProfile({
    required String name,
    required String phoneNumber,
  });
}

//--- Device Repository ---
abstract class DeviceRepository {
  Future<Either<Failure, Device>> addDevice(
    String name,
    String subtitle,
    String iconAsset,
    int roomId,
    DeviceType deviceType,
  );
  Future<Either<Failure, Unit>> deleteDevice(int deviceId);
  Future<Either<Failure, Device>> updateDevice(
    int deviceId,
    String name,
    String subtitle,
  );
}

//--- Room Repository ---
abstract class RoomRepository {
  Future<Either<Failure, List<Room>>> getRooms();
  Future<Either<Failure, Room>> addRoom(String name);
  Future<Either<Failure, Unit>> deleteRoom(int roomId);
  Future<Either<Failure, Room>> updateRoom(int roomId, String name);
}