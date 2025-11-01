// Lưu Ngọc Thiện 

// lib/domain/entities/user.dart

// Import thư viện 'equatable' để hỗ trợ việc so sánh các đối tượng User.
// Khi kế thừa từ Equatable, hai đối tượng User sẽ được coi là bằng nhau
// nếu tất cả các thuộc tính trong `props` (ở cuối file) của chúng giống hệt nhau.
import 'package:equatable/equatable.dart';

// Định nghĩa một class (lớp) User.
// Đây là một "entity" (thực thể) trong miền (domain),
// đại diện cho mô hình dữ liệu người dùng trong ứng dụng.
// Kế thừa `Equatable` để đơn giản hóa việc so sánh đối tượng.
class User extends Equatable {
  // Các thuộc tính (fields) của đối tượng User.
  // `final` có nghĩa là chúng không thể thay đổi sau khi đối tượng được tạo (immutable).
  final int id; // ID của người dùng
  final String name; // Tên của người dùng
  final String email; // Email của người dùng
  final String phoneNumber; // Số điện thoại của người dùng

  // Constructor (hàm khởi tạo) mặc định của class.
  // Nó yêu cầu tất cả các thuộc tính phải được cung cấp khi tạo một đối tượng User.
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });


  // Một "factory constructor" tên là `fromJson`.
  // Factory constructor là một cách để tạo ra một instance (đối tượng) của class.
  // Hàm này dùng để chuyển đổi một `Map<String, dynamic>` (thường nhận từ JSON API)
  // thành một đối tượng `User`.
  factory User.fromJson(Map<String, dynamic> json) {
    // Trả về một đối tượng User mới với dữ liệu được trích xuất từ `json`.
    return User(
      id: json['id'], // Lấy giá trị của key 'id'.
      name: json['name'], // Lấy giá trị của key 'name'.
      email: json['email'], // Lấy giá trị của key 'email'.
      phoneNumber: json['phone_number'], // Lấy giá trị của key 'phone_number'.
    );
  }


  // ===================== NEW METHOD =====================
  // Phương thức `copyWith` (sao chép với...).
  // Đây là một mẫu (pattern) phổ biến khi làm việc với các đối tượng immutable (bất biến).
  // Nó tạo ra một bản sao *mới* của đối tượng User hiện tại,
  // nhưng cho phép bạn "ghi đè" các giá trị cụ thể nếu chúng được cung cấp.
  User copyWith({String? name, String? email, String? phoneNumber}) {
    // Trả về một đối tượng User mới
    return User(
      // Giữ nguyên `id` của đối tượng gốc (vì nó không được phép thay đổi).
      id: id,
      // Nếu `name` *mới* được cung cấp (không phải null), dùng nó.
      // Nếu không (`??`), dùng giá trị `name` của đối tượng hiện tại (`this.name`).
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
  // ===================== END OF NEW METHOD =====================
  
  
  @override
  // Ghi đè phương thức `props` từ `Equatable`.
  // Danh sách này nói cho `Equatable` biết những thuộc tính nào
  // cần được sử dụng để so sánh sự bằng nhau.
  // Hai đối tượng User có cùng `id`, `name`, `email`, `phoneNumber` sẽ được coi là bằng nhau.
  List<Object?> get props => [id, name, email, phoneNumber];
}
