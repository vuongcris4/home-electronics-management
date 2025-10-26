// lib/domain/usecases/add_device_usecase.dart
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
    // Pass the new deviceType parameter to the repository
    return await repository.addDevice(params.name, params.subtitle,
        params.iconAsset, params.roomId, params.deviceType);
  }
}

class AddDeviceParams extends Equatable {
  final String name;
  final String subtitle;
  final String iconAsset;
  final int roomId;
  final DeviceType deviceType; // <-- ADDED

  const AddDeviceParams({
    required this.name,
    required this.subtitle,
    required this.iconAsset,
    required this.roomId,
    required this.deviceType, // <-- ADDED
  });

  @override
  List<Object> get props => [name, subtitle, iconAsset, roomId, deviceType];
}