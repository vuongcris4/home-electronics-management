// lib/infrastructure/room/room_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/error/app_error.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories.dart';
import 'room_data_source.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomRemoteDataSource remote;

  RoomRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<Room>>> getRooms() async {
    try {
      final rooms = await remote.getRooms();
      return Right(rooms);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Room>> addRoom(String name) async {
    try {
      final room = await remote.addRoom(name);
      return Right(room);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRoom(int roomId) async {
    try {
      await remote.deleteRoom(roomId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Room>> updateRoom(int roomId, String name) async {
    try {
      final room = await remote.updateRoom(roomId, name);
      return Right(room);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}