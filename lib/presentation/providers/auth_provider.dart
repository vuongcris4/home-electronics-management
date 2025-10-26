// lib/presentation/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../../core/error/failures.dart'; // <-- ADD THIS IMPORT
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

enum ViewState { Idle, Loading, Success, Error }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
  });

  ViewState _loginState = ViewState.Idle; // Các biến private để lưu trạng thái hiện tại của tác vụ đăng nhập và đăng ký. UI sẽ "lắng nghe" sự thay đổi của các biến này để tự cập nhật.
  ViewState get loginState => _loginState;

  ViewState _registerState = ViewState.Idle;
  ViewState get registerState => _registerState;  // getter

  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  
  void _setLoginState(ViewState state) {
    _loginState = state;
    notifyListeners();
  }

  void _setRegisterState(ViewState state) {
    _registerState = state;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoginState(ViewState.Loading);  // rebuild lại UI với trạng thái loading

    final result = await loginUseCase(LoginParams(email: email, password: password)); // tầng presentation gọi tầng domain

    bool isSuccess = false;
    result.fold(
      (failure) {
        _errorMessage = failure is ServerFailure ? failure.message : 'Lỗi không xác định';
        // rebuild lại UI với trạng thái Error
        _setLoginState(ViewState.Error);  // để notifyListeners() → widget tự rebuild
        isSuccess = false;
      },
      (_) {
        // rebuild lại UI với trạng thái Success
        _setLoginState(ViewState.Success); // Nếu comment lại thì nút login sẽ quay vòng liên tục vì k rebuild UI để cập nhật state
        isSuccess = true;
      },
    );
    return isSuccess; // Trả kết quả logic về cho widget hiện tại đang gọi, dùng return isSuccess để biết hành động kế tiếp (ví dụ: chuyển trang, show dialog)
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String password2,
    required String phoneNumber,
  }) async {
    _setRegisterState(ViewState.Loading);
    
    final params = RegisterParams(
      name: name,
      email: email,
      password: password,
      password2: password2,
      phoneNumber: phoneNumber,
    );
    final result = await registerUseCase(params);

    bool isSuccess = false;
    result.fold(
      (failure) {
        _errorMessage = failure is ServerFailure ? failure.message : 'Lỗi không xác định';
        _setRegisterState(ViewState.Error);
        isSuccess = false;
      },
      (_) {
        _setRegisterState(ViewState.Success);
        isSuccess = true;
      },
    );
    return isSuccess;
  }
}