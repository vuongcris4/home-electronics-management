// lib/core/error/app_error.dart
import 'package:equatable/equatable.dart';

// --- Failures ---
// Dùng ở tầng Domain và Presentation, là phiên bản "an toàn" của Exception.
abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);

  @override
  List<Object> get props => [];
}

// Lỗi chung khi gọi API (VD: 404, 500)
class ServerFailure extends Failure {
  final String message;
  const ServerFailure(this.message);

  @override
  List<Object> get props => [message];
}

// Lỗi khi cache dữ liệu
class CacheFailure extends Failure {}


// --- Exceptions ---
// Phát sinh ở tầng Data Source, sẽ được chuyển đổi thành Failure.
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class CacheException implements Exception {}