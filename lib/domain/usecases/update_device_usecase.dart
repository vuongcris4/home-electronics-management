// lib/domain/usecases/update_device_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/device.dart';
import '../repositories/device_repository.dart';

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