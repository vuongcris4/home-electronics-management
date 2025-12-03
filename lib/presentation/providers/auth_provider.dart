// lib/presentation/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories.dart';

enum ViewState { Idle, Loading, Success, Error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthProvider({required this.authRepository});

  ViewState _loginState = ViewState.Idle;
  ViewState get loginState => _loginState;

  ViewState _registerState = ViewState.Idle;
  ViewState get registerState => _registerState;

  ViewState _profileState = ViewState.Idle;
  ViewState get profileState => _profileState;

  ViewState _updateProfileState = ViewState.Idle;
  ViewState get updateProfileState => _updateProfileState;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  User? _user;
  User? get user => _user;

  // ... (Giữ nguyên hàm clearUserData, các hàm _setState) ...
  void clearUserData() {
    _user = null;
    _profileState = ViewState.Idle;
    _loginState = ViewState.Idle;
    _registerState = ViewState.Idle;
    _updateProfileState = ViewState.Idle;
    _errorMessage = '';
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

  void _setProfileState(ViewState state) {
    _profileState = state;
    notifyListeners();
  }

  void _setUpdateProfileState(ViewState state) {
    _updateProfileState = state;
    notifyListeners();
  }

  // --- LOGIN ---
  Future<bool> login(String email, String password) async {
    _setLoginState(ViewState.Loading);
    try {
      // Gọi repository, nếu lỗi nó sẽ nhảy xuống catch
      await authRepository.login(email, password);

      _setLoginState(ViewState.Success);
      return true;
    } catch (e) {
      // Lấy message từ Exception (bỏ chữ "Exception: " nếu có)
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _setLoginState(ViewState.Error);
      return false;
    }
  }

  // --- REGISTER ---
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String password2,
    required String phoneNumber,
  }) async {
    _setRegisterState(ViewState.Loading);
    try {
      await authRepository.register(
        name: name,
        email: email,
        password: password,
        password2: password2,
        phoneNumber: phoneNumber,
      );
      _setRegisterState(ViewState.Success);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _setRegisterState(ViewState.Error);
      return false;
    }
  }

  // --- GET PROFILE ---
  Future<void> fetchUserProfile() async {
    if (_profileState == ViewState.Loading || _user != null) return;
    _setProfileState(ViewState.Loading);
    try {
      _user = await authRepository.getUserProfile();
      _setProfileState(ViewState.Success);
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _setProfileState(ViewState.Error);
    }
  }

  // --- UPDATE PROFILE ---
  Future<bool> updateProfile(
      {required String name, required String phoneNumber}) async {
    _setUpdateProfileState(ViewState.Loading);
    try {
      _user = await authRepository.updateUserProfile(
          name: name, phoneNumber: phoneNumber);
      _setUpdateProfileState(ViewState.Success);
      Future.delayed(const Duration(seconds: 1),
          () => _setUpdateProfileState(ViewState.Idle));
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _setUpdateProfileState(ViewState.Error);
      return false;
    }
  }
}
