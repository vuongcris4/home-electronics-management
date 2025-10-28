  // lib/domain/usecases/update_room_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/room.dart';
import '../repositories/room_repository.dart';

class UpdateRoomUseCase implements UseCase<Room, UpdateRoomParams> {
  final RoomRepository repository;

  UpdateRoomUseCase(this.repository);

  @override
  Future<Either<Failure, Room>> call(UpdateRoomParams params) async {
    return await repository.updateRoom(params.id, params.name);
  }
}

class UpdateRoomParams extends Equatable {
  final int id;
  final String name;

  const UpdateRoomParams({required this.id, required this.name});

  @override
  List<Object> get props => [id, name];
}