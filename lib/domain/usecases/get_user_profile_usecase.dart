// lib/domain/usecases/get_user_profile_usecase.dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetUserProfileUseCase implements UseCase<User, NoParams> {
  final AuthRepository repository;
  GetUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return repository.getUserProfile();
  }
}