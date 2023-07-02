import 'package:geolocator/geolocator.dart';

class User {
  final String? id;
  final String? name;
  final String? email;
  final String? password;
  final String? confirmPassword;
  late final Position? position;

  User({
    this.id,
    this.name,
    this.email,
    this.password,
    this.confirmPassword,
    this.position,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      confirmPassword: json['confirmPassword'] as String?,
      position: Position.fromMap(json['position']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'position': position?.toJson(),
    };
  }
}
