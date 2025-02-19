import 'package:locadora_flutter/src/enum/enum_role.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? password;
  final EnumRole role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      role: EnumRole.fromString(json['role'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role.toString(),
    };
  }
}
