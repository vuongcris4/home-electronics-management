// lib/domain/usecases/device_usecases.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/app_error.dart';
import '../../core/usecase/usecase.dart';
import '../entities/device.dart';
import '../repositories.dart';

// --- Add Device ---
class AddDeviceUseCase implements UseCase<Device, AddDeviceParams> {
  final DeviceRepository repository;
  AddDeviceUseCase(this.repository);

  @override
  Future<Either<Failure, Device>> call(AddDeviceParams params) async {
    return await repository.addDevice(params.name, params.subtitle,
        params.iconAsset, params.roomId, params.deviceType);
  }
}

class AddDeviceParams extends Equatable {
  final String name;
  final String subtitle;
  final String iconAsset;
  final int roomId;
  final DeviceType deviceType;

  const AddDeviceParams({
    required this.name,
    required this.subtitle,
    required this.iconAsset,
    required this.roomId,
    required this.deviceType,
  });

  @override
  List<Object> get props => [name, subtitle, iconAsset, roomId, deviceType];
}


// --- Delete Device ---
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

// --- Update Device ---
class UpdateDeviceUseCase implements UseCase<Device, UpdateDeviceParams> {
  final DeviceRepository repository;
  UpdateDeviceUseCase(this.repository);

  @override
  Future<Either<Failure, Device>> call(UpdateDeviceParams params) async {
    return await repository.updateDevice(
        params.id, params.name, params.subtitle);
  }
}

class UpdateDeviceParams extends Equatable {
  final int id;
  final String name;
  final String subtitle;

  const UpdateDeviceParams({
    required this.id,
    required this.name,
    required this.subtitle,
  });

  @override
  List<Object> get props => [id, name, subtitle];
}