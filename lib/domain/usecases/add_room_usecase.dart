import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/room.dart';
import '../repositories/room_repository.dart';

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
