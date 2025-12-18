// lib/infrastructure/room/room_repository_impl.dart
import 'package:dio/dio.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories.dart';

class RoomRepositoryImpl implements RoomRepository {
  final Dio dio;

  // Constructor nhận Dio để gọi API
  RoomRepositoryImpl({required this.dio});

  // Lấy Danh sách Rooms: nhận dữ liệu JSON và trả về thành List<Room>
  @override
  Future<List<Room>> getRooms() async {
    try {
      final response = await dio.get('/rooms/');
      return (response.data as List)
          .map((e) => Room.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception("Failed to load rooms: $e");
    }
  }

  // Thêm Room: với tham số name
  @override
  Future<Room> addRoom(String name) async {
    try {
      final response = await dio.post(
        '/rooms/',
        data: {'name': name},
      );
      return Room.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to add room: $e");
    }
  }

  // Deleete Room với tham số rooomId
  @override
  Future<void> deleteRoom(int roomId) async {
    try {
      await dio.delete('/rooms/$roomId/');
    } catch (e) {
      throw Exception("Failed to delete room: $e");
    }
  }

  @override
  Future<Room> updateRoom(int roomId, String name) async {
    try {
      final response = await dio.put(
        '/rooms/$roomId/',
        data: {'name': name},
      );
      return Room.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to update room: $e");
    }
  }
}