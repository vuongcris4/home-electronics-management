// lib/core/usecase/usecase.dart
import 'package:dartz/dartz.dart'; // Thư viện cho Either
import 'package:equatable/equatable.dart';
import '../error/app_error.dart'; // Lớp Failure đã định nghĩa

// 1. Lớp trừu tượng UseCase
// Đây là một lớp trừu tượng (abstract class) sử dụng Generics (kiểu dữ liệu chung).
// Type: Đại diện cho kiểu dữ liệu trả về khi use case thành công. Ví dụ: List<Room> cho GetRoomsUseCase, Device 
// cho AddDeviceUseCase, hoặc Unit (từ dartz, nghĩa là không có gì) cho LoginUseCase.
// Params: Đại diện cho các tham số đầu vào mà use case cần để thực thi. Ví dụ: LoginParams chứa email và password.
abstract class UseCase<Type, Params> {
  // call(...): Đây là một phương thức đặc biệt trong Dart. Nó cho phép bạn gọi một đối tượng của lớp như một hàm. 
  // Thay vì viết getRoomsUseCase.call(NoParams()), bạn có thể viết gọn là getRoomsUseCase(NoParams()).
  // Future<...>: Báo hiệu đây là một hoạt động bất đồng bộ (asynchronous), thường là vì nó cần gọi API hoặc truy cập database.
  // Either<Failure, Type>: Đây là phần "ma thuật" từ thư viện dartz. Either là một kiểu dữ liệu có thể chứa một trong hai giá trị:
  // Bên trái (Left): Theo quy ước, dùng để chứa lỗi. Trong trường hợp này là một đối tượng Failure (ví dụ: ServerFailure).
  // Bên phải (Right): Theo quy ước, dùng để chứa kết quả thành công. Trong trường hợp này là dữ liệu có kiểu Type.
  Future<Either<Failure, Type>> call(Params params);
}

// 3. Lớp dành cho use case không cần tham số
class NoParams extends Equatable {
  // Đây là một lớp đơn giản được dùng làm tham số cho các use case không yêu cầu dữ liệu đầu vào,
  // ví dụ như GetRoomsUseCase (lấy tất cả các phòng).
  @override
  List<Object> get props => [];
}