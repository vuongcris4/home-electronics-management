import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id; 
  final String name; 
  final String email; 
  final String phoneNumber; 

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });


  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], 
      name: json['name'], 
      email: json['email'], 
      phoneNumber: json['phone_number'], 
    );
  }

  User copyWith({String? name, String? email, String? phoneNumber}) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
  
  @override
  List<Object?> get props => [id, name, email, phoneNumber];
}
