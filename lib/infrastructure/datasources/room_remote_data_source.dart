import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/room.dart';

abstract class RoomRemoteDataSource {
  Future<List<Room>> getRooms();
  Future<Room> addRoom(String name);
  Future<void> deleteRoom(int roomId);
}

class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage storage;
  final String _baseUrl = "https://mrh3.dongnama.app/api";

  RoomRemoteDataSourceImpl({required this.client, required this.storage});

  Future<Map<String, String>> _headers() async {
    final token = await storage.read(key: 'access_token');
    if (token == null) throw ServerException("Token not found");
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<Room>> getRooms() async {
    final res = await client.get(Uri.parse('$_baseUrl/rooms/'), headers: await _headers());
    if (res.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(res.bodyBytes));
      return jsonList.map((e) => Room.fromJson(e)).toList();
    }
    throw ServerException("Failed to load rooms");
  }

  @override
  Future<Room> addRoom(String name) async {
    final res = await client.post(
      Uri.parse('$_baseUrl/rooms/'),
      headers: await _headers(),
      body: jsonEncode({'name': name}),
    );
    if (res.statusCode == 201) {
      return Room.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
    }
    throw ServerException("Failed to add room");
  }

  @override
  Future<void> deleteRoom(int roomId) async {
    final res = await client.delete(
      Uri.parse('$_baseUrl/rooms/$roomId/'), headers: await _headers(),
    );
    if (res.statusCode != 204) throw ServerException("Failed to delete room");
  }
}
