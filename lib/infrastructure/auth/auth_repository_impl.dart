// lib/infrastructure/auth/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/error/app_error.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio dio;
  final FlutterSecureStorage storage;

  AuthRepositoryImpl({
    required this.dio,
    required this.storage,
  });

  @override
  Future<Either<Failure, Unit>> login(String email, String password) async {
    try {
      // 1. Gọi API Login
      final response = await dio.post(
        '/token/',
        data: {'email': email, 'password': password},
      );

      // 2. Lưu token vào Storage
      final accessToken = response.data['access'];
      final refreshToken = response.data['refresh'];
      
      await storage.write(key: 'access_token', value: accessToken);
      await storage.write(key: 'refresh_token', value: refreshToken);

      return const Right(unit);
    } on DioException catch (e) {
      // Xử lý lỗi Dio trực tiếp tại đây
      if (e.response?.statusCode == 401) {
        return const Left(ServerFailure("Email hoặc mật khẩu không đúng."));
      }
      return Left(ServerFailure(e.response?.data['detail'] ?? 'Lỗi đăng nhập'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> register({
    required String name,
    required String email,
    required String password,
    required String password2,
    required String phoneNumber,
  }) async {
    try {
      await dio.post(
        '/users/register/',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password2': password2,
          'phone_number': phoneNumber,
        },
      );
      return const Right(unit);
    } on DioException catch (e) {
      String errorMessage = "Đã có lỗi xảy ra.";
      if (e.response?.data is Map) {
        final responseBody = e.response!.data as Map<String, dynamic>;
        final firstError = responseBody.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          errorMessage = firstError.first.toString();
        } else {
          errorMessage = firstError.toString();
        }
      }
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserProfile() async {
    try {
      final response = await dio.get('/users/me/');
      return Right(User.fromJson(response.data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['detail'] ?? 'Failed to get user profile'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile({
    required String name,
    required String phoneNumber,
  }) async {
    try {
      final response = await dio.patch(
        '/users/me/',
        data: {
          'name': name,
          'phone_number': phoneNumber,
        },
      );
      return Right(User.fromJson(response.data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['detail'] ?? 'Failed to update user profile'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}