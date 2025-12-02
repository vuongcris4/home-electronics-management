// lib/infrastructure/device/device_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/error/app_error.dart';
import '../../domain/entities/device.dart';
import '../../domain/repositories.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final Dio dio;

  DeviceRepositoryImpl({required this.dio});

  @override
  Future<Either<Failure, Device>> addDevice(
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
      return Right(Device.fromJson(res.data));
    } on DioException {
      return const Left(ServerFailure("Failed to add device"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteDevice(int deviceId) async {
    try {
      final res = await dio.delete('/devices/$deviceId/');
      if (res.statusCode != 204) {
         return const Left(ServerFailure("Failed to delete device"));
      }
      return const Right(unit);
    } on DioException {
      return const Left(ServerFailure("Failed to delete device"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Device>> updateDevice(
      int deviceId, String name, String subtitle) async {
    try {
      final res = await dio.put(
        '/devices/$deviceId/',
        data: {
          'name': name,
          'subtitle': subtitle,
        },
      );
      return Right(Device.fromJson(res.data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['detail'] ?? "Failed to update device"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}