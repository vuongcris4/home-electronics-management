// lib/domain/usecases/login_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

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