// lib/infrastructure/device/device_repository_impl.dart
import 'package:dio/dio.dart';
import '../../domain/entities/device.dart';
import '../../domain/repositories.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final Dio dio;

  DeviceRepositoryImpl({required this.dio});

  @override
  Future<Device> addDevice(String name, String subtitle, String iconAsset, int roomId, DeviceType deviceType) async {
    try {
      final res = await dio.post(
        '/devices/',
        data: {
          'name': name,
          'subtitle': subtitle,
          'icon_asset': iconAsset,
          'room': roomId,
          'device_type': deviceType.name,
        },
      );
      return Device.fromJson(res.data);
    } catch (e) {
      throw Exception("Failed to add device: $e");
    }
  }

  @override
  Future<void> deleteDevice(int deviceId) async {
    try {
      await dio.delete('/devices/$deviceId/');
    } catch (e) {
      throw Exception("Failed to delete device: $e");
    }
  }

  @override
  Future<Device> updateDevice(int deviceId, String name, String subtitle) async {
    try {
      final res = await dio.put(
        '/devices/$deviceId/',
        data: {
          'name': name,
          'subtitle': subtitle,
        },
      );
      return Device.fromJson(res.data);
    } catch (e) {
      throw Exception("Failed to update device: $e");
    }
  }
}