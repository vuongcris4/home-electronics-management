// lib/domain/usecases/room_usecases.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/app_error.dart';
import '../../core/usecase/usecase.dart';
import '../entities/room.dart';
import '../repositories.dart';

// --- Get Rooms ---
class GetRoomsUseCase implements UseCase<List<Room>, NoParams> {
  final RoomRepository repository;
  GetRoomsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Room>>> call(NoParams params) {
    return repository.getRooms();
  }
}

// --- Add Room ---
class AddRoomUseCase implements UseCase<Room, AddRoomParams> {
  final RoomRepository repository;
  AddRoomUseCase(this.repository);

  @override
  Future<Either<Failure, Room>> call(AddRoomParams params) {
    return repository.addRoom(params.name);
  }
}

class AddRoomParams extends Equatable {
  final String name;
  const AddRoomParams({required this.name});
  @override
  List<Object> get props => [name];
}

// --- Delete Room ---
class DeleteRoomUseCase implements UseCase<Unit, DeleteRoomParams> {
  final RoomRepository repository;
  DeleteRoomUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteRoomParams params) {
    return repository.deleteRoom(params.roomId);
  }
}

class DeleteRoomParams extends Equatable {
  final int roomId;
  const DeleteRoomParams({required this.roomId});
  @override
  List<Object> get props => [roomId];
}

// --- Update Room ---
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