import 'package:geolocator/geolocator.dart';

class User {
  final String? userId;
  final String? name;
  final String? email;
  final String? password;
  final String? confirmPassword;
  late final Position? position;

  User({
    this.userId,
    this.name,
    this.email,
    this.password,
    this.confirmPassword,
    this.position,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      confirmPassword: json['confirmPassword'] as String?,
      position: Position.fromMap(json['position']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'position': position?.toJson(),
    };
  }
}
