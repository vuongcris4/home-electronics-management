import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/room.dart';
import '../repositories/device_repository.dart';

class GetRoomsUseCase implements UseCase<List<Room>, NoParams> {
  final DeviceRepository repository;

  GetRoomsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Room>>> call(NoParams params) async {
    return await repository.getRooms();
  }
}