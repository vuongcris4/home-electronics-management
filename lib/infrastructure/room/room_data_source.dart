import 'package:dio/dio.dart'; // (Lớp 4) Thư viện dùng để thực hiện các cuộc gọi HTTP
import '../../core/error/app_error.dart'; // Định nghĩa các lớp Exception tùy chỉnh
import '../../domain/entities/room.dart'; // (Lớp 2) Import Entity 'Room' để map dữ liệu trả về

// Đây là một "Interface" (hay abstract class) định nghĩa "hợp đồng"
// cho bất kỳ nguồn dữ liệu (Data Source) nào liên quan đến Room.
// Lớp Repository (ở Lớp 3) sẽ phụ thuộc vào Interface này,
// chứ không phải vào lớp Implementation bên dưới.
abstract class RoomRemoteDataSource {
  Future<List<Room>> getRooms();
  Future<Room> addRoom(String name);
  Future<void> deleteRoom(int roomId);
  Future<Room> updateRoom(int roomId, String name);
}

// Đây là lớp "Implementation" (triển khai) của Interface ở trên.
// Lớp này biết CÁCH LÀM THẾ NÀO để lấy dữ liệu, cụ thể là dùng 'Dio'.
class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  // Nó phụ thuộc vào Dio (được cung cấp từ bên ngoài - Dependency Injection)
  final Dio dio;

  RoomRemoteDataSourceImpl({required this.dio});

  // Triển khai hàm lấy danh sách phòng
  @override
  Future<List<Room>> getRooms() async {
    try {
      // 1. Thực hiện cuộc gọi 'GET' đến endpoint '/rooms/'
      final res = await dio.get('/rooms/');
      
      // 2. Lấy dữ liệu thô (dạng List<dynamic> chứa các Map JSON)
      final List<dynamic> jsonList = res.data;

      // 3. Chuyển đổi (map) từng Map JSON trong danh sách
      // thành đối tượng 'Room' (Entity của Lớp 2) bằng hàm 'Room.fromJson'.
      return jsonList.map((e) => Room.fromJson(e)).toList();
    } on DioException {
      // 4. Nếu Dio ném ra lỗi (mất mạng, 404, 500, ...),
      // "bắt" nó lại và ném ra một 'ServerException' (lỗi của ứng dụng).
      // Điều này giúp che giấu chi tiết kỹ thuật (Dio) khỏi các lớp bên trên.
      throw ServerException("Failed to load rooms");
    }
  }

  // Triển khai hàm thêm phòng mới
  @override
  Future<Room> addRoom(String name) async {
    try {
      // 1. Thực hiện cuộc gọi 'POST', gửi 'name' trong 'data' (body) của request
      final res = await dio.post('/rooms/', data: {'name': name});
      
      // 2. API trả về đối tượng Room vừa tạo (dưới dạng JSON),
      // chuyển đổi nó thành Entity 'Room' và trả về.
      return Room.fromJson(res.data);
    } on DioException {
      // 3. Xử lý lỗi tương tự như trên.
      throw ServerException("Failed to add room");
    }
  }

  // Triển khai hàm xóa phòng
  @override
  Future<void> deleteRoom(int roomId) async {
    try {
      // 1. Thực hiện cuộc gọi 'DELETE' đến endpoint cụ thể (ví dụ: /rooms/123/)
      final res = await dio.delete('/rooms/$roomId/');
      
      // 2. Thông thường, một cuộc gọi DELETE thành công sẽ trả về
      // status code '204 No Content'.
      // (Lưu ý: Dio có thể đã được cấu hình để ném Exception
      // nếu status code không phải là 2xx, 
      // nên việc check này có thể là một lớp bảo vệ bổ sung).
      if (res.statusCode != 204) throw ServerException("Failed to delete room");
    } on DioException {
      // 3. Xử lý lỗi.
      throw ServerException("Failed to delete room");
    }
  }

  // Triển khai hàm cập nhật phòng
  @override
  Future<Room> updateRoom(int roomId, String name) async {
    try {
      // 1. Thực hiện cuộc gọi 'PUT' (hoặc 'PATCH') đến endpoint cụ thể,
      // gửi 'name' mới trong 'data' (body).
      final res = await dio.put('/rooms/$roomId/', data: {'name': name});
      
      // 2. API trả về đối tượng Room đã được cập nhật (dạng JSON),
      // chuyển đổi nó thành Entity 'Room'.
      return Room.fromJson(res.data);
    } on DioException {
      // 3. Xử lý lỗi.
      throw ServerException("Failed to update room");
    }
  }
}