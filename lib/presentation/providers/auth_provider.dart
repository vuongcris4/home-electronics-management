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

  void _setState(ViewState state) {
    if (state == ViewState.Loading) {
      _loginState = ViewState.Loading;
      _registerState = ViewState.Loading;
    }
    notifyListeners();
  }
  
  void _setLoginState(ViewState state) {
    _loginState = state;
    notifyListeners();
  }

  void _setRegisterState(ViewState state) {
    _registerState = state;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoginState(ViewState.Loading);

    final result = await loginUseCase(LoginParams(email: email, password: password)); // tầng presentation gọi tầng domain

    bool isSuccess = false;
    result.fold(
      (failure) {
        _errorMessage = failure is ServerFailure ? failure.message : 'Lỗi không xác định';
        _setLoginState(ViewState.Error);
        isSuccess = false;
      },
      (_) {
        _setLoginState(ViewState.Success);
        isSuccess = true;
      },
    );
    return isSuccess;
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