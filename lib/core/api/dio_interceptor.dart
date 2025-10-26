import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../injection_container.dart'; // Giả sử GetIt ở đây

class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Tự động thêm access token vào header của mọi request
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

            // Cập nhật header của request bị lỗi và thử lại
            err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final response = await dio.fetch(err.requestOptions);
            return handler.resolve(response);
          }
        } catch (e) {
          // Nếu refresh token cũng lỗi, xóa token và logout
          await _logout(storage);
          return handler.next(err);
        }
      }
      // Nếu không có refresh token, cũng logout
      await _logout(storage);
    }
    return handler.next(err);
  }
  
  Future<void> _logout(FlutterSecureStorage storage) async {
      await storage.delete(key: 'access_token');
      await storage.delete(key: 'refresh_token');
      // Ở đây bạn có thể điều hướng người dùng về màn hình login
      // Cần một cơ chế global navigation hoặc dùng callback.
  }
}