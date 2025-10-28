// lib/infrastructure/auth/auth_repository_impl.dart
import 'package:dartz/dartz.dart';

import '../../core/error/app_error.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories.dart';
import 'auth_data_sources.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Unit>> login(String email, String password) async {
    try {
      final tokenData = await remoteDataSource.login(email, password);
      await localDataSource.cacheTokens(
        accessToken: tokenData['access'],
        refreshToken: tokenData['refresh'],
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> register({
    required String name,
    required String email,
    required String password,
    required String password2,
    required String phoneNumber,
  }) async {
    try {
      await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        password2: password2,
        phoneNumber: phoneNumber,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> getUserProfile() async {
    try {
      final user = await remoteDataSource.getUserProfile();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile(
      {required String name, required String phoneNumber}) async {
    try {
      final user = await remoteDataSource.updateUserProfile(
        name: name,
        phoneNumber: phoneNumber,
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}