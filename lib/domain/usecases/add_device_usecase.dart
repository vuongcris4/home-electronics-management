import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/device.dart';
import '../repositories/device_repository.dart';

class AddDeviceUseCase implements UseCase<Device, AddDeviceParams> {
  final DeviceRepository repository;

  AddDeviceUseCase(this.repository);

  @override
  Future<Either<Failure, Device>> call(AddDeviceParams params) async {
    return await repository.addDevice(params.name, params.subtitle, params.iconAsset, params.roomId);
  }
}

class AddDeviceParams extends Equatable {
  final String name;
  final String subtitle;
  final String iconAsset;
  final int roomId;

  const AddDeviceParams({
    required this.name,
    required this.subtitle,
    required this.iconAsset,
    required this.roomId,
  });

  @override
  List<Object> get props => [name, subtitle, iconAsset, roomId];
}