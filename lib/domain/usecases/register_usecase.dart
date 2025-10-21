// lib/domain/usecases/register_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

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