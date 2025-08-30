import 'dart:convert';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String name,
    required String role,
    required String email,
    required String phone,
    String? profileImage,
    required DateTime createdAt,
    required bool isActive,
    Map<String, dynamic>? settings,
    List<String>? favorites,
  }) : super(
          id: id,
          name: name,
          role: role,
          email: email,
          phone: phone,
          profileImage: profileImage,
          createdAt: createdAt,
          isActive: isActive,
          settings: settings,
          favorites: favorites,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      profileImage: json['profileImage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool,
      settings: json['settingsJson'] != null
          ? jsonDecode(json['settingsJson'] as String) as Map<String, dynamic>?
          : null,
      favorites: json['favoritesJson'] != null
          ? (jsonDecode(json['favoritesJson'] as String) as List<dynamic>?)
              ?.map((e) => e as String)
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'settingsJson': settings != null ? jsonEncode(settings) : null,
      'favoritesJson': favorites != null ? jsonEncode(favorites) : null,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      role: user.role,
      email: user.email,
      phone: user.phone,
      profileImage: user.profileImage,
      createdAt: user.createdAt,
      isActive: user.isActive,
      settings: user.settings,
      favorites: user.favorites,
    );
  }
}