// lib/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

// interface cho repository theo clean architecture
abstract class AuthRepository {
  // 1. Phương thức login
  Future<Either<Failure, Unit>> login(String email, String password);
  // 2. Phương thức register
  Future<Either<Failure, Unit>> register({
    required String name,
    required String email,
    required String password,
    required String password2,
    required String phoneNumber,
  });
}