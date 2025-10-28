// lib/domain/usecases/update_user_profile_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

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