// lib/infrastructure/datasources/auth_remote_data_source.dart
import 'dart:convert';
import 'package:dio/dio.dart'; // <-- Sửa import
import '../../core/error/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String password2,
    required String phoneNumber,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio; // <-- Sửa ở đây

  AuthRemoteDataSourceImpl({required this.dio}); // <-- Sửa ở đây

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/token/',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ServerException("Email hoặc mật khẩu không đúng.");
      }
      throw ServerException(e.response?.data['detail'] ?? 'Lỗi đăng nhập');
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
        final firstError = responseBody.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          errorMessage = firstError.first.toString();
        } else {
          errorMessage = firstError.toString();
        }
      }
      throw ServerException(errorMessage);
    }
  }
}
