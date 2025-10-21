import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../repositories/room_repository.dart';

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
