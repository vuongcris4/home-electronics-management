// lib/infrastructure/datasources/auth_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
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
  final http.Client client;
  final String _baseUrl = "https://mrh3.dongnama.app/api";

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/token/'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ServerException("Email hoặc mật khẩu không đúng.");
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
    final response = await client.post(
      Uri.parse('$_baseUrl/users/register/'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password2': password2,
        'phone_number': phoneNumber,
      }),
    );

    if (response.statusCode != 201) {
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      String errorMessage = "Đã có lỗi xảy ra.";
       if (responseBody is Map<String, dynamic> && responseBody.isNotEmpty) {
          final firstError = responseBody.values.first;
          if(firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first.toString();
          } else {
            errorMessage = firstError.toString();
          }
       }
      throw ServerException(errorMessage);
    }
  }
}