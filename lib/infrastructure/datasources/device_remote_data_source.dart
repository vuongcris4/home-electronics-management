// lib/infrastructure/datasources/device_remote_data_source.dart
import 'package:dio/dio.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/device.dart';

abstract class DeviceRemoteDataSource {
  Future<Device> addDevice(
    String name,
    String subtitle,
    String iconAsset,
    int roomId,
    DeviceType deviceType,
  );
  Future<void> deleteDevice(int deviceId);
  // ===================== THÊM MỚI =====================
  Future<Device> updateDevice(
    int deviceId,
    String name,
    String subtitle,
  );
  // ===================== KẾT THÚC =====================
}

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final Dio dio;

  DeviceRemoteDataSourceImpl({required this.dio});

  @override
  Future<Device> addDevice(
    String name,
    String subtitle,
    String iconAsset,
    int roomId,
    DeviceType deviceType,
  ) async {
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
    } on DioException {
      throw ServerException("Failed to add device");
    }
  }

  @override
  Future<void> deleteDevice(int deviceId) async {
    try {
      final res = await dio.delete('/devices/$deviceId/');
      if (res.statusCode != 204) {
        throw ServerException("Failed to delete device");
      }
    } on DioException {
      throw ServerException("Failed to delete device");
    }
  }

  // ===================== THÊM MỚI =====================
  @override
  Future<Device> updateDevice(
      int deviceId, String name, String subtitle) async {
    try {
      final res = await dio.put(
        '/devices/$deviceId/',
        data: {
          'name': name,
          'subtitle': subtitle,
        },
      );
      return Device.fromJson(res.data);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? "Failed to update device");
    }
  }
  // ===================== KẾT THÚC =====================
}