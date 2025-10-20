import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Thay thế bằng URL backend của bạn
  final String _baseUrl = "https://mrh3.dongnama.app/api";

  // Hàm đăng ký
  Future<http.Response> register(
    String name,
    String email,
    String password,
    String password2,
    String phoneNumber,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/register/'),
      headers: <String, String>{
        // Sửa ở dòng này: UTF-T -> UTF-8
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password,
        'password2': password2,
        'phone_number': phoneNumber,
      }),
    );
    return response;
  }

  // Hàm đăng nhập
  Future<http.Response> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/token/'), // Endpoint đăng nhập
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    return response;
  }
}