// lib/presentation/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../../core/error/app_error.dart';
import '../../core/usecase/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';

enum ViewState { Idle, Loading, Success, Error }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
  });

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

  Future<bool> login(String email, String password) async {
    _setLoginState(ViewState.Loading);
    final result =
        await loginUseCase(LoginParams(email: email, password: password));

    bool isSuccess = false;
    result.fold(
      (failure) {
        _errorMessage =
            failure is ServerFailure ? failure.message : 'Lỗi không xác định';
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
        _errorMessage =
            failure is ServerFailure ? failure.message : 'Lỗi không xác định';
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

  Future<void> fetchUserProfile() async {
    if (_profileState == ViewState.Loading || _user != null) return;

    _setProfileState(ViewState.Loading);
    final result = await getUserProfileUseCase(NoParams());

    result.fold(
      (failure) {
        _errorMessage =
            failure is ServerFailure ? failure.message : 'Unknown Error';
        _setProfileState(ViewState.Error);
      },
      (userData) {
        _user = userData;
        _setProfileState(ViewState.Success);
      },
    );
  }

  Future<bool> updateProfile({
    required String name,
    required String phoneNumber,
  }) async {
    _setUpdateProfileState(ViewState.Loading);

    final params = UpdateUserParams(name: name, phoneNumber: phoneNumber);
    final result = await updateUserProfileUseCase(params);

    bool isSuccess = false;
    result.fold(
      (failure) {
        _errorMessage =
            failure is ServerFailure ? failure.message : 'Update failed';
        _setUpdateProfileState(ViewState.Error);
        isSuccess = false;
      },
      (updatedUser) {
        _user = updatedUser;
        _setUpdateProfileState(ViewState.Success);
        isSuccess = true;
      },
    );
    
    Future.delayed(const Duration(seconds: 1), () => _setUpdateProfileState(ViewState.Idle));

    return isSuccess;
  }


}
