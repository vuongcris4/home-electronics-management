// lib/infrastructure/room/room_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/error/app_error.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories.dart';

class RoomRepositoryImpl implements RoomRepository {
  final Dio dio;

  RoomRepositoryImpl({required this.dio});

  @override
  Future<Either<Failure, List<Room>>> getRooms() async {
    try {
      final res = await dio.get('/rooms/');
      final List<dynamic> jsonList = res.data;
      final rooms = jsonList.map((e) => Room.fromJson(e)).toList();
      return Right(rooms);
    } on DioException {
      return const Left(ServerFailure("Failed to load rooms"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Room>> addRoom(String name) async {
    try {
      final res = await dio.post('/rooms/', data: {'name': name});
      return Right(Room.fromJson(res.data));
    } on DioException {
      return const Left(ServerFailure("Failed to add room"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRoom(int roomId) async {
    try {
      final res = await dio.delete('/rooms/$roomId/');
      if (res.statusCode != 204) {
         return const Left(ServerFailure("Failed to delete room"));
      }
      return const Right(unit);
    } on DioException {
      return const Left(ServerFailure("Failed to delete room"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Room>> updateRoom(int roomId, String name) async {
    try {
      final res = await dio.put('/rooms/$roomId/', data: {'name': name});
      return Right(Room.fromJson(res.data));
    } on DioException {
      return const Left(ServerFailure("Failed to update room"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}