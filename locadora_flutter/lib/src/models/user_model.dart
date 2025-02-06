enum EnumRole {
  ADMIN,
  USER;

  @override
  String toString() {
    return name.toUpperCase();
  }

  static EnumRole fromString(String role) {
    return EnumRole.values.firstWhere(
        (e) => e.name.toUpperCase() == role.toUpperCase(),
        orElse: () => throw ArgumentError('Invalid role: $role'));
  }
}

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
