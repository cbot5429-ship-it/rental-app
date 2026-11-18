import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isAdmin;

  UserProfile({
    required this.id,
    this.fullName,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
    required this.isAdmin,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isAdmin: json['is_admin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'is_admin': isAdmin,
    };
  }

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? avatarUrl,
    DateTime? createdAt,
    bool? isAdmin,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

extension SupabaseUser on User {
  UserProfile toProfile() => UserProfile(
    id: id,
    fullName: userMetadata?['full_name'] as String?,
    phone: userMetadata?['phone'] as String?,
    avatarUrl: userMetadata?['avatar_url'] as String?,
    createdAt: createdAt,
    isAdmin: userMetadata?['is_admin'] as bool? ?? false,
  );
}