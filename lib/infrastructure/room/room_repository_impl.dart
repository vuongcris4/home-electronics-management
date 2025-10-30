// lib/infrastructure/room/room_repository_impl.dart

// Import thư viện 'dartz' để sử dụng 'Either' (cho xử lý lỗi) và 'Unit' (cho void)
import 'package:dartz/dartz.dart';
// Import các lớp lỗi tùy chỉnh (Failure, ServerException, ServerFailure)
import '../../core/error/app_error.dart';
// Import định nghĩa (entity) của Room
import '../../domain/entities/room.dart';
// Import 'RoomRepository' (lớp "hợp đồng" trừu tượng từ domain)
import '../../domain/repositories.dart';
// Import 'RoomRemoteDataSource' (lớp "hợp đồng" trừu tượng từ infrastructure)
import 'room_data_source.dart';

// Đây là lớp "triển khai" (implementation) của 'RoomRepository'.
// Nhiệm vụ của lớp này là:
// 1. Gọi các hàm từ 'RoomRemoteDataSource' (lớp gọi API).
// 2. Bắt (catch) các lỗi (ví dụ: ServerException) nếu có.
// 3. Chuyển đổi kết quả/lỗi thành dạng 'Either<Failure, T>' mà UseCase (ở domain) mong muốn.
class RoomRepositoryImpl implements RoomRepository {
  // Lớp này phụ thuộc vào một 'RoomRemoteDataSource'
  final RoomRemoteDataSource remote;

  // Constructor: Yêu cầu 'remote' phải được cung cấp (dependency injection)
  RoomRepositoryImpl({required this.remote});

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