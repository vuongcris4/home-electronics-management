// lib/domain/repositories/room_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/room.dart';

abstract class RoomRepository {
  // lấy ds phòng
  Future<Either<Failure, List<Room>>> getRooms();
  // thêm phòng
  Future<Either<Failure, Room>> addRoom(String name);
  // xoá phòng
  Future<Either<Failure, Unit>> deleteRoom(int roomId);
  // ===================== THÊM MỚI =====================
  Future<Either<Failure, Room>> updateRoom(int roomId, String name);
  // ===================== KẾT THÚC =====================
}