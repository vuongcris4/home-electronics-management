// lib/infrastructure/room/room_data_source.dart

// Import thư viện 'Dio' (dùng để thực hiện các cuộc gọi HTTP API)
import 'package:dio/dio.dart';
// Import các lớp lỗi tùy chỉnh (ServerException)
import '../../core/error/app_error.dart';
// Import định nghĩa (entity) của Room
import '../../domain/entities/room.dart';

// Định nghĩa một lớp 'abstract' (trừu tượng) cho Nguồn dữ liệu từ xa (Remote DataSource) của Room.
// Lớp này hoạt động như một "hợp đồng" (contract),
// nó định nghĩa CÁC HÀM CẦN CÓ, nhưng không định nghĩa CÁCH THỰC HIỆN chúng.
abstract class RoomRemoteDataSource {
  // Hợp đồng: Cần có hàm 'getRooms' trả về một danh sách Room
  Future<List<Room>> getRooms();
  // Hợp đồng: Cần có hàm 'addRoom' trả về Room vừa được tạo
  Future<Room> addRoom(String name);
  // Hợp đồng: Cần có hàm 'deleteRoom' (không trả về gì - void)
  Future<void> deleteRoom(int roomId);
  // Hợp đồng: Cần có hàm 'updateRoom' trả về Room vừa được cập nhật
  Future<Room> updateRoom(int roomId, String name);
}

// Đây là lớp "triển khai" (implementation) của hợp đồng 'RoomRemoteDataSource'.
// Lớp này định nghĩa CÁCH THỰC HIỆN các hàm.
class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  // Lớp này phụ thuộc vào một instance của Dio
  final Dio dio;

  // Constructor: Yêu cầu 'dio' phải được cung cấp (dependency injection)
  RoomRemoteDataSourceImpl({required this.dio});

  @override
  // Triển khai hàm 'getRooms'
  Future<List<Room>> getRooms() async {
    try {
      // Thực hiện cuộc gọi HTTP GET đến endpoint '/rooms/'
      final res = await dio.get('/rooms/');
      // Lấy dữ liệu (data) từ response (thường là một danh sách JSON)
      final List<dynamic> jsonList = res.data;
      // Dùng hàm 'map' để biến đổi từng item JSON trong 'jsonList'
      // thành một đối tượng 'Room' bằng cách gọi 'Room.fromJson()',
      // sau đó chuyển kết quả thành một List<Room>.
      return jsonList.map((e) => Room.fromJson(e)).toList();
    } on DioException {
      // Nếu có lỗi từ Dio (ví dụ: 404, 500, không có mạng),
      // ném (throw) ra một lỗi ServerException tùy chỉnh
      throw ServerException("Failed to load rooms");
    }
  }

  @override
  // Triển khai hàm 'addRoom'
  Future<Room> addRoom(String name) async {
    try {
      // Thực hiện cuộc gọi HTTP POST đến '/rooms/'
      // Gửi kèm 'data' là tên của phòng mới
      final res = await dio.post('/rooms/', data: {'name': name});
      // Server sẽ trả về JSON của phòng vừa được tạo,
      // parse nó thành đối tượng Room và trả về
      return Room.fromJson(res.data);
    } on DioException {
      // Bắt lỗi DioException
      throw ServerException("Failed to add room");
    }
  }

  @override
  // Triển khai hàm 'deleteRoom'
  Future<void> deleteRoom(int roomId) async {
    try {
      // Thực hiện cuộc gọi HTTP DELETE đến '/rooms/<roomId>/'
      final res = await dio.delete('/rooms/$roomId/');
      // Thông thường, server trả về status code 204 (No Content) khi DELETE thành công
      // Nếu code không phải là 204, coi đó là lỗi
      if (res.statusCode != 204) throw ServerException("Failed to delete room");
    } on DioException {
      // Bắt lỗi DioException
      throw ServerException("Failed to delete room");
    }
  }

  @override
  // Triển khai hàm 'updateRoom'
  Future<Room> updateRoom(int roomId, String name) async {
    try {
      // Thực hiện cuộc gọi HTTP PUT (hoặc PATCH) đến '/rooms/<roomId>/'
      // Gửi kèm 'data' là tên mới
      final res = await dio.put('/rooms/$roomId/', data: {'name': name});
      // Server trả về JSON của phòng đã được cập nhật,
      // parse nó thành đối tượng Room và trả về
      return Room.fromJson(res.data);
    } on DioException {
      // Bắt lỗi DioException
      throw ServerException("Failed to update room");
    }
  }
}