// lib/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, Unit>> login(String email, String password);
  Future<Either<Failure, Unit>> register({
    required String name,
    required String email,
    required String password,
    required String password2,
    required String phoneNumber,
  });
}