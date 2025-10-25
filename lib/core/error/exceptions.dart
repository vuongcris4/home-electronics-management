// lib/core/error/exceptions.dart


//Exception ở tầng Data
// Đây là các ngoại lệ (exception) phát sinh ở tầng Data Source (ví dụ: khi gọi API hoặc đọc local storage).
// Mục tiêu: nếu lỗi xảy ra ở tầng thấp (data), không để nó “rò rỉ” lên domain, mà sẽ được chuyển đổi thành Failure tương ứng ở tầng Domain.
// Lỗi từ API / server  HTTP 404, 500, timeout…

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class CacheException implements Exception {}