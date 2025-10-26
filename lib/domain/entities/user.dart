// lib/domain/entities/user.dart
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

  @override
  List<Object?> get props => [id, name, email, phoneNumber];
}