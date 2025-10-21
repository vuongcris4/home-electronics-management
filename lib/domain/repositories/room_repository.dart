import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/room.dart';

abstract class RoomRepository {
  Future<Either<Failure, List<Room>>> getRooms();
  Future<Either<Failure, Room>> addRoom(String name);
  Future<Either<Failure, Unit>> deleteRoom(int roomId);
}
