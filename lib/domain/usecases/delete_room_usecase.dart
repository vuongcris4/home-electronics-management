import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../repositories/device_repository.dart';

class DeleteRoomUseCase implements UseCase<Unit, DeleteRoomParams> {
  final DeviceRepository repository;

  DeleteRoomUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteRoomParams params) async {
    return await repository.deleteRoom(params.roomId);
  }
}

class DeleteRoomParams extends Equatable {
  final int roomId;

  const DeleteRoomParams({required this.roomId});

  @override
  List<Object> get props => [roomId];
}