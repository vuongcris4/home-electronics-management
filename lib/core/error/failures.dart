// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

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