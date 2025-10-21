import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/device.dart'; // Thêm import
import '../../domain/entities/room.dart';

abstract class DeviceRemoteDataSource {
  Future<List<Room>> getRooms();
  Future<Room> addRoom(String name);
  Future<void> deleteRoom(int roomId);
  Future<Device> addDevice(String name, String subtitle, String iconAsset, int roomId);
  Future<void> deleteDevice(int deviceId);
}

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage storage;
  final String _baseUrl = "https://mrh3.dongnama.app/api";

  DeviceRemoteDataSourceImpl({required this.client, required this.storage});
  
  // Hàm helper để lấy header có token
  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'access_token');
    if (token == null) {
      throw ServerException("Token not found");
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<Room>> getRooms() async {
    final response = await client.get(
      Uri.parse('$_baseUrl/rooms/'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Room.fromJson(json)).toList();
    } else {
      throw ServerException("Failed to load rooms");
    }
  }

  @override
  Future<Room> addRoom(String name) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/rooms/'),
      headers: await _getHeaders(),
      body: jsonEncode({'name': name}),
    );
    if (response.statusCode == 201) {
      return Room.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw ServerException("Failed to add room");
    }
  }

  @override
  Future<void> deleteRoom(int roomId) async {
    final response = await client.delete(
      Uri.parse('$_baseUrl/rooms/$roomId/'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 204) {
      throw ServerException("Failed to delete room");
    }
  }

  @override
  Future<Device> addDevice(String name, String subtitle, String iconAsset, int roomId) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/devices/'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'name': name,
        'subtitle': subtitle,
        'icon_asset': iconAsset,
        'room': roomId,
      }),
    );
     if (response.statusCode == 201) {
      return Device.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw ServerException("Failed to add device");
    }
  }
  
  @override
  Future<void> deleteDevice(int deviceId) async {
    final response = await client.delete(
      Uri.parse('$_baseUrl/devices/$deviceId/'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 204) {
      throw ServerException("Failed to delete device");
    }
  }
}