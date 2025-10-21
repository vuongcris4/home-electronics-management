import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/room.dart';
import '../repositories/room_repository.dart';

class GetRoomsUseCase implements UseCase<List<Room>, NoParams> {
  final RoomRepository repository;
  GetRoomsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Room>>> call(NoParams params) {
    return repository.getRooms();
  }
}
