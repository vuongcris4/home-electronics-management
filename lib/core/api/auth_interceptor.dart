// lib/core/api/auth_interceptor.dart

// Auth Interceptor là lớp giúp:
// 1. Tự động gắn Access Token vào mỗi API request
// 2. Tự động refresh token khi Access token hết hạn
// 3. Tự động retry request sau khi refresh token thành công
// 4. Tự logout và điều hướng về login nếu refresh token cũng hết hạn.

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../injection_container.dart';
import '../navigation/navigation_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Không đính kèm token cho các request login/register/refresh
    if (options.path.endsWith('/token/') ||
        options.path.endsWith('/register/') ||
        options.path.endsWith('/token/refresh/')) {
      return handler.next(options);
    }
    
    // Tự động thêm access token vào header
    final storage = getIt<FlutterSecureStorage>();
    final token = await storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Nếu lỗi là 401 Unauthorized và không phải từ endpoint refresh token
    if (err.response?.statusCode == 401 && !err.requestOptions.path.endsWith('/token/refresh/')) {
      final storage = getIt<FlutterSecureStorage>();
      final refreshToken = await storage.read(key: 'refresh_token');

      if (refreshToken != null) {
        try {
          // Gửi yêu cầu lấy token mới
          final refreshResponse = await dio.post(
            'https://mrh3.dongnama.app/api/token/refresh/',
            data: {'refresh': refreshToken},
          );

          if (refreshResponse.statusCode == 200) {
            // Lưu token mới
            final newAccessToken = refreshResponse.data['access'];
            await storage.write(key: 'access_token', value: newAccessToken);
            
            // Có thể backend của bạn cũng trả về refresh token mới, hãy xử lý nó nếu cần
            // final newRefreshToken = refreshResponse.data['refresh'];
            // await storage.write(key: 'refresh_token', value: newRefreshToken);

            // Cập nhật header của request bị lỗi và thử lại
            err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final response = await dio.fetch(err.requestOptions);
            return handler.resolve(response);
          }
        } catch (e) {
          // Nếu refresh token cũng lỗi, xóa token và logout
          print("Refresh token failed, logging out.");
          await _logout(storage);
          return handler.next(err); 
        }
      }
      
      // Nếu không có refresh token, cũng logout
      print("No refresh token, logging out.");
      await _logout(storage);
    }
    return handler.next(err);
  }
  
  Future<void> _logout(FlutterSecureStorage storage) async {
      await storage.delete(key: 'access_token');
      await storage.delete(key: 'refresh_token');
      
      // Dùng NavigationService để điều hướng về màn hình login
      final navigationService = getIt<NavigationService>();
      navigationService.pushNamedAndRemoveUntil('/login');
  }
}