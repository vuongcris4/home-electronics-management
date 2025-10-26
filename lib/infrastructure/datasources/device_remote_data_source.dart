// lib/infrastructure/datasources/device_remote_data_source.dart
import 'package:dio/dio.dart'; // <-- Sửa import
import '../../core/error/exceptions.dart';
import '../../domain/entities/device.dart';

abstract class DeviceRemoteDataSource {
  Future<Device> addDevice(
      String name, String subtitle, String iconAsset, int roomId);
  Future<void> deleteDevice(int deviceId);
}

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final Dio dio; // <-- Sửa ở đây

  DeviceRemoteDataSourceImpl({required this.dio}); // <-- Sửa ở đây

  @override
  Future<Device> addDevice(
      String name, String subtitle, String iconAsset, int roomId) async {
    try {
      final res = await dio.post(
        '/devices/',
        data: {
          'name': name,
          'subtitle': subtitle,
          'icon_asset': iconAsset,
          'room': roomId
        },
      );
      return Device.fromJson(res.data);
    } on DioException {
      throw ServerException("Failed to add device");
    }
  }

  @override
  Future<void> deleteDevice(int deviceId) async {
    try {
      final res = await dio.delete('/devices/$deviceId/');
      if (res.statusCode != 204)
        throw ServerException("Failed to delete device");
    } on DioException {
      throw ServerException("Failed to delete device");
    }
  }
}
