// lib/core/error/failures.dart

// Failure là phiên bản "an toàn" của Exception, được dùng ở tầng Domain và Presentation.
// Thay vì ném try-catch lung tung, ta trả về đối tượng Failure nằm trong Either (thư viện dartz).
// Equatable giúp so sánh object dễ dàng (test dễ hơn).

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);

  @override
  List<Object> get props => [];
}

// Lỗi chung khi gọi API (VD: 404, 500), Lỗi kết nối mạng, HTTP status code lỗi
class ServerFailure extends Failure {
  final String message;
  const ServerFailure(this.message);
  
   @override
  List<Object> get props => [message];
}

// Lỗi khi cache dữ liệu
class CacheFailure extends Failure {}