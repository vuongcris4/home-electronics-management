// lib/presentation/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart'; // <-- HINZUGEFÜGT
import '../../domain/entities/user.dart'; // <-- HINZUGEFÜGT
import '../../domain/usecases/get_user_profile_usecase.dart'; // <-- HINZUGEFÜGT
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

enum ViewState { Idle, Loading, Success, Error }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GetUserProfileUseCase getUserProfileUseCase; // <-- HINZUGEFÜGT

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.getUserProfileUseCase, // <-- HINZUGEFÜGT
  });

  ViewState _loginState = ViewState.Idle;
  ViewState get loginState => _loginState;

  ViewState _registerState = ViewState.Idle;
  ViewState get registerState => _registerState;

  ViewState _profileState = ViewState.Idle; // <-- HINZUGEFÜGT
  ViewState get profileState => _profileState; // <-- HINZUGEFÜGT

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  User? _user; // <-- HINZUGEFÜGT
  User? get user => _user; // <-- HINZUGEFÜGT

  void _setLoginState(ViewState state) {
    _loginState = state;
    notifyListeners();
  }

  void _setRegisterState(ViewState state) {
    _registerState = state;
    notifyListeners();
  }

  void _setProfileState(ViewState state) {
    // <-- HINZUGEFÜGT
    _profileState = state;
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

  // --- DIESE METHODE HINZUFÜGEN ---
  Future<void> fetchUserProfile() async {
    // Verhindern Sie das Abrufen, wenn bereits geladen wird oder geladen ist
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
}