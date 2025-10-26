// lib/infrastructure/datasources/room_remote_data_source.dart
import 'package:dio/dio.dart'; // <-- Sửa import
import '../../core/error/exceptions.dart';
import '../../domain/entities/room.dart';

abstract class RoomRemoteDataSource {
  Future<List<Room>> getRooms();
  Future<Room> addRoom(String name);
  Future<void> deleteRoom(int roomId);
}

class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  final Dio dio; // <-- Sửa ở đây

  RoomRemoteDataSourceImpl({required this.dio}); // <-- Sửa ở đây

  @override
  Future<List<Room>> getRooms() async {
    try {
      final res = await dio.get('/rooms/');
      final List<dynamic> jsonList = res.data;
      return jsonList.map((e) => Room.fromJson(e)).toList();
    } on DioException {
      throw ServerException("Failed to load rooms");
    }
  }

  @override
  Future<Room> addRoom(String name) async {
    try {
      final res = await dio.post('/rooms/', data: {'name': name});
      return Room.fromJson(res.data);
    } on DioException {
      throw ServerException("Failed to add room");
    }
  }

  @override
  Future<void> deleteRoom(int roomId) async {
    try {
      final res = await dio.delete('/rooms/$roomId/');
      if (res.statusCode != 204) throw ServerException("Failed to delete room");
    } on DioException {
      throw ServerException("Failed to delete room");
    }
  }
}
