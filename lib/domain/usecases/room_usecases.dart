// lib/domain/usecases/room_usecases.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/app_error.dart';
import '../../core/usecase/usecase.dart';
import '../entities/room.dart';
import '../repositories.dart';

// Lớp 'UseCase' này chịu trách nhiệm cho nghiệp vụ "Lấy tất cả các phòng".
// Nó implement lớp UseCase cơ sở, chỉ định rằng nó sẽ trả về List<Room>
// và không cần tham số đầu vào (NoParams).
class GetRoomsUseCase implements UseCase<List<Room>, NoParams> {
  // UseCase phụ thuộc vào một 'Repository' (Interface), chứ không phải 'Implementation'.
  // Điều này tuân thủ Dependency Inversion Principle (chữ 'D' trong SOLID).
  final RoomRepository repository;
  GetRoomsUseCase(this.repository);

  // Khi UseCase này được gọi, nó chỉ đơn giản là chuyển tiếp lệnh gọi
  // đến phương thức getRooms() của repository.
  @override
  Future<Either<Failure, List<Room>>> call(NoParams params) {
    return repository.getRooms();
  }
}

// --- Add Room ---
// Lớp 'UseCase' này chịu trách nhiệm cho nghiệp vụ "Thêm một phòng mới".
// Nó sẽ trả về đối tượng 'Room' vừa được tạo và cần tham số 'AddRoomParams'.
class AddRoomUseCase implements UseCase<Room, AddRoomParams> {
  final RoomRepository repository;
  AddRoomUseCase(this.repository);

  // Khi được gọi, nó lấy 'name' từ 'params' và chuyển tiếp lệnh gọi
  // đến phương thức addRoom() của repository.
  @override
  Future<Either<Failure, Room>> call(AddRoomParams params) {
    return repository.addRoom(params.name);
  }
}

// Lớp này dùng để đóng gói các tham số cần thiết cho AddRoomUseCase.
// Dùng Equatable để có thể so sánh các đối tượng AddRoomParams với nhau
// (ví dụ: trong unit test hoặc khi dùng với BLoC/Provider).
class AddRoomParams extends Equatable {
  final String name;
  const AddRoomParams({required this.name});
  
  // Thuộc tính props này được Equatable sử dụng để so sánh.
  @override
  List<Object> get props => [name];
}

// --- Delete Room ---
// Lớp 'UseCase' này chịu trách nhiệm cho nghiệp vụ "Xóa một phòng".
// Nó sẽ trả về 'Unit' (tương đương 'void' cho kiểu Either) khi thành công
// và cần tham số 'DeleteRoomParams'.
class DeleteRoomUseCase implements UseCase<Unit, DeleteRoomParams> {
  final RoomRepository repository;
  DeleteRoomUseCase(this.repository);

  // Khi được gọi, nó lấy 'roomId' từ 'params' và chuyển tiếp lệnh gọi
  // đến phương thức deleteRoom() của repository.
  @override
  Future<Either<Failure, Unit>> call(DeleteRoomParams params) {
    return repository.deleteRoom(params.roomId);
  }
}

// Lớp đóng gói tham số cho DeleteRoomUseCase.
class DeleteRoomParams extends Equatable {
  final int roomId;
  const DeleteRoomParams({required this.roomId});
  @override
  List<Object> get props => [roomId];
}

// --- Update Room ---
// Lớp 'UseCase' này chịu trách nhiệm cho nghiệp vụ "Cập nhật tên một phòng".
// Nó sẽ trả về đối tượng 'Room' đã được cập nhật
// và cần tham số 'UpdateRoomParams'.
class UpdateRoomUseCase implements UseCase<Room, UpdateRoomParams> {
  final RoomRepository repository;
  UpdateRoomUseCase(this.repository);

  @override
  Future<Either<Failure, Room>> call(UpdateRoomParams params) async {
    // Lấy id và name từ params và gọi hàm repository tương ứng.
    return await repository.updateRoom(params.id, params.name);
  }
}

// Lớp đóng gói tham số cho UpdateRoomUseCase.
class UpdateRoomParams extends Equatable {
  final int id;
  final String name;

  const UpdateRoomParams({required this.id, required this.name});

  @override
  List<Object> get props => [id, name];
}