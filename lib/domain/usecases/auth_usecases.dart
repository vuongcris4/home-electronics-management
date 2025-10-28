// lib/domain/usecases/auth_usecases.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/app_error.dart';
import '../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories.dart';

// --- Login ---
class LoginUseCase implements UseCase<Unit, LoginParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

// --- Register ---
class RegisterUseCase implements UseCase<Unit, RegisterParams> {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(RegisterParams params) async {
    return await repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      password2: params.password2,
      phoneNumber: params.phoneNumber,
    );
  }
}

class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String password;
  final String password2;
  final String phoneNumber;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.password2,
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [name, email, password, password2, phoneNumber];
}


// --- Get User Profile ---
class GetUserProfileUseCase implements UseCase<User, NoParams> {
  final AuthRepository repository;
  GetUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return repository.getUserProfile();
  }
}

// --- Update User Profile ---
class UpdateUserProfileUseCase implements UseCase<User, UpdateUserParams> {
  final AuthRepository repository;
  UpdateUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateUserParams params) async {
    return await repository.updateUserProfile(
      name: params.name,
      phoneNumber: params.phoneNumber,
    );
  }
}

class UpdateUserParams extends Equatable {
  final String name;
  final String phoneNumber;

  const UpdateUserParams({
    required this.name,
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [name, phoneNumber];
}