import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../repositories/device_repository.dart';

class DeleteDeviceUseCase implements UseCase<Unit, DeleteDeviceParams> {
  final DeviceRepository repository;

  DeleteDeviceUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteDeviceParams params) async {
    return await repository.deleteDevice(params.deviceId);
  }
}

class DeleteDeviceParams extends Equatable {
  final int deviceId;

  const DeleteDeviceParams({required this.deviceId});

  @override
  List<Object> get props => [deviceId];
}