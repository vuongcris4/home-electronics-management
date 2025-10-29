import 'package:dartz/dartz.dart'; // Thư viện cung cấp kiểu 'Either' để xử lý lỗi
import '../../core/error/app_error.dart'; // Định nghĩa các lớp Failure (ServerFailure)
import '../../domain/entities/room.dart'; // (Lớp 2) Import Entity
import '../../domain/repositories.dart'; // (Lớp 2) Import Interface 'RoomRepository'
import 'room_data_source.dart'; // (Lớp 3) Import Interface 'RoomRemoteDataSource'

// Đây là lớp "Implementation" (triển khai) của Interface 'RoomRepository'
// mà Lớp 2 (Domain) đã định nghĩa.
// Nhiệm vụ của nó là điều phối dữ liệu từ các nguồn khác nhau (ví dụ: remote, local)
// và xử lý các lỗi (Exception) từ các nguồn đó.
class RoomRepositoryImpl implements RoomRepository {
  // Repository phụ thuộc vào 'Interface' của Data Source (ví dụ: RoomRemoteDataSource)
  // chứ không phải 'Implementation' (RoomRemoteDataSourceImpl).
  // Điều này cho phép dễ dàng thay thế nguồn dữ liệu (ví dụ: mock, local)
  // mà không cần thay đổi Repository.
  final RoomRemoteDataSource remote;

  RoomRepositoryImpl({required this.remote});

  // Triển khai hàm lấy danh sách phòng
  @override
  Future<Either<Failure, List<Room>>> getRooms() async {
    try {
      // 1. Gọi hàm lấy dữ liệu từ Data Source (remote).
      // Data Source sẽ trả về List<Room> hoặc ném ra 'ServerException'.
      final rooms = await remote.getRooms();

      // 2. Nếu cuộc gọi thành công, gói kết quả (List<Room>)
      // vào bên 'Right' của 'Either'. 'Right' luôn đại diện cho thành công.
      return Right(rooms);
    } on ServerException catch (e) {
      // 3. Nếu Data Source ném ra 'ServerException' (đã được bắt ở lớp Data),
      // "bắt" nó lại và chuyển đổi nó thành 'ServerFailure'.
      // Gói 'Failure' này vào bên 'Left' của 'Either'. 'Left' luôn đại diện cho lỗi.
      // Điều này ngăn chặn Exception bị ném lên Lớp Domain (UseCase),
      // Lớp Domain giờ đây chỉ cần xử lý kiểu Either<Failure, Success>.
      return Left(ServerFailure(e.message));
    }
  }

  // Triển khai hàm thêm phòng
  @override
  Future<Either<Failure, Room>> addRoom(String name) async {
    try {
      // 1. Gọi remote Data Source
      final room = await remote.addRoom(name);
      // 2. Thành công -> trả về Right(Room)
      return Right(room);
    } on ServerException catch (e) {
      // 3. Thất bại -> bắt Exception và trả về Left(Failure)
      return Left(ServerFailure(e.message));
    }
  }

  // Triển khai hàm xóa phòng
  @override
  Future<Either<Failure, Unit>> deleteRoom(int roomId) async {
    try {
      // 1. Gọi remote Data Source. Hàm này (deleteRoom) không trả về gì (Future<void>).
      await remote.deleteRoom(roomId);
      // 2. Nếu không có lỗi, trả về 'Right(unit)'.
      // 'unit' là một hằng số từ 'dartz' đại diện cho 'void' (thành công nhưng không có data).
      return const Right(unit);
    } on ServerException catch (e) {
      // 3. Thất bại -> trả về Left(Failure)
      return Left(ServerFailure(e.message));
    }
  }

  // Triển khai hàm cập nhật phòng
  @override
  Future<Either<Failure, Room>> updateRoom(int roomId, String name) async {
    try {
      // 1. Gọi remote Data Source
      final room = await remote.updateRoom(roomId, name);
      // 2. Thành công -> trả về Right(Room)
      return Right(room);
    } on ServerException catch (e) {
      // 3. Thất bại -> trả về Left(Failure)
      return Left(ServerFailure(e.message));
    }
  }
}