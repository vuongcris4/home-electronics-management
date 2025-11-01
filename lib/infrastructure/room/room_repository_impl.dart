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

  // Constructor: Yêu cầu 'remote' phải được cung cấp (dependency injection)
  RoomRepositoryImpl({required this.remote});

  // Triển khai hàm lấy danh sách phòng
  @override
  // Triển khai hàm 'getRooms'
  // Trả về 'Either' (Hoặc 'Failure' (Lỗi), Hoặc 'List<Room>' (Thành công))
  Future<Either<Failure, List<Room>>> getRooms() async {
    try {
      // 1. Gọi hàm 'getRooms' từ remote data source (lấy dữ liệu từ API)
      final rooms = await remote.getRooms();
      // 2. Nếu thành công, trả về kết quả (danh sách rooms) bọc trong 'Right'
      return Right(rooms);
    } on ServerException catch (e) {
      // 3. Nếu remote data source ném ra 'ServerException'
      // Bắt (catch) lỗi đó, bọc nó trong 'ServerFailure' và trả về 'Left'
      return Left(ServerFailure(e.message));
    }
  }

  // Triển khai hàm thêm phòng
  @override
  // Triển khai hàm 'addRoom'
  Future<Either<Failure, Room>> addRoom(String name) async {
    try {
      // 1. Gọi hàm 'addRoom' từ remote data source
      final room = await remote.addRoom(name);
      // 2. Nếu thành công, trả về 'Room' mới bọc trong 'Right'
      return Right(room);
    } on ServerException catch (e) {
      // 3. Nếu lỗi, trả về 'Left'
      return Left(ServerFailure(e.message));
    }
  }

  // Triển khai hàm xóa phòng
  @override
  // Triển khai hàm 'deleteRoom'
  // 'Unit' (từ dartz) là kiểu đại diện cho 'void' (không có data trả về)
  Future<Either<Failure, Unit>> deleteRoom(int roomId) async {
    try {
      // 1. Gọi hàm 'deleteRoom' từ remote data source (hàm này là Future<void>)
      await remote.deleteRoom(roomId);
      // 2. Nếu thành công (không có exception), trả về 'unit' bọc trong 'Right'
      return const Right(unit);
    } on ServerException catch (e) {
      // 3. Nếu lỗi, trả về 'Left'
      return Left(ServerFailure(e.message));
    }
  }

  // Triển khai hàm cập nhật phòng
  @override
  // Triển khai hàm 'updateRoom'
  Future<Either<Failure, Room>> updateRoom(int roomId, String name) async {
    try {
      // 1. Gọi hàm 'updateRoom' từ remote data source
      final room = await remote.updateRoom(roomId, name);
      // 2. Nếu thành công, trả về 'Room' đã cập nhật bọc trong 'Right'
      return Right(room);
    } on ServerException catch (e) {
      // 3. Nếu lỗi, trả về 'Left'
      return Left(ServerFailure(e.message));
    }
  }
}