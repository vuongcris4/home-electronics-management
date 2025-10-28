// lib/infrastructure/datasources/room_remote_data_source.dart
import 'package:dio/dio.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/room.dart';

abstract class RoomRemoteDataSource {
  Future<List<Room>> getRooms();
  Future<Room> addRoom(String name);
  Future<void> deleteRoom(int roomId);
  // ===================== THÊM MỚI =====================
  Future<Room> updateRoom(int roomId, String name);
  // ===================== KẾT THÚC =====================
}

class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  final Dio dio;

  RoomRemoteDataSourceImpl({required this.dio});

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

  // ===================== THÊM MỚI =====================
  @override
  Future<Room> updateRoom(int roomId, String name) async {
    try {
      final res = await dio.put('/rooms/$roomId/', data: {'name': name});
      return Room.fromJson(res.data);
    } on DioException {
      throw ServerException("Failed to update room");
    }
  }
  // ===================== KẾT THÚC =====================
}