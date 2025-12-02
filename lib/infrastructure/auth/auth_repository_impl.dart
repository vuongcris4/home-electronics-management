// lib/infrastructure/auth/auth_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  Future<void> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/token/',
        data: {'email': email, 'password': password},
      );

      final accessToken = response.data['access'];
      final refreshToken = response.data['refresh'];
      
      await storage.write(key: 'access_token', value: accessToken);
      await storage.write(key: 'refresh_token', value: refreshToken);
    } on DioException catch (e) {
      // Ném ra Exception thông thường để Provider bắt
      if (e.response?.statusCode == 401) {
        throw Exception("Email hoặc mật khẩu không đúng.");
      }
      throw Exception(e.response?.data['detail'] ?? 'Lỗi đăng nhập');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> register({
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
    } on DioException catch (e) {
      String errorMessage = "Đã có lỗi xảy ra.";
      if (e.response?.data is Map) {
        final responseBody = e.response!.data as Map<String, dynamic>;
        // Logic lấy message lỗi đầu tiên
        final firstError = responseBody.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          errorMessage = firstError.first.toString();
        } else {
          errorMessage = firstError.toString();
        }
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<User> getUserProfile() async {
    try {
      final response = await dio.get('/users/me/');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to get user profile');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<User> updateUserProfile({
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
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to update profile');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}