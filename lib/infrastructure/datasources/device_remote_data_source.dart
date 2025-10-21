import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/device.dart';

abstract class DeviceRemoteDataSource {
  Future<Device> addDevice(String name, String subtitle, String iconAsset, int roomId);
  Future<void> deleteDevice(int deviceId);
}

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage storage;
  final String _baseUrl = "https://mrh3.dongnama.app/api";

  DeviceRemoteDataSourceImpl({required this.client, required this.storage});

  Future<Map<String, String>> _headers() async {
    final token = await storage.read(key: 'access_token');
    if (token == null) throw ServerException("Token not found");
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<Device> addDevice(String name, String subtitle, String iconAsset, int roomId) async {
    final res = await client.post(
      Uri.parse('$_baseUrl/devices/'),
      headers: await _headers(),
      body: jsonEncode({'name': name, 'subtitle': subtitle, 'icon_asset': iconAsset, 'room': roomId}),
    );
    if (res.statusCode == 201) {
      return Device.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
    }
    throw ServerException("Failed to add device");
  }

  @override
  Future<void> deleteDevice(int deviceId) async {
    final res = await client.delete(
      Uri.parse('$_baseUrl/devices/$deviceId/'), headers: await _headers(),
    );
    if (res.statusCode != 204) throw ServerException("Failed to delete device");
  }
}
