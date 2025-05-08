import 'package:flutter/material.dart';

// Додамо enum для статусів верифікації
enum VerificationStatus {
  notVerified,    // Не верифіковано
  pending,        // На перевірці
  verified        // Верифіковано
}

// Допоміжний метод для конвертації між типами
extension VerificationStatusExtension on VerificationStatus {
  String toJson() {
    switch (this) {
      case VerificationStatus.notVerified:
        return 'not_verified';
      case VerificationStatus.pending:
        return 'pending';
      case VerificationStatus.verified:
        return 'verified';
    }
  }

  static VerificationStatus fromJson(String? json) {
    switch (json) {
      case 'verified':
        return VerificationStatus.verified;
      case 'pending':
        return VerificationStatus.pending;
      case 'not_verified':
      default:
        return VerificationStatus.notVerified;
    }
  }
  
  // Метод для отримання зрозумілої назви статусу українською
  String toUkrainianString() {
    switch (this) {
      case VerificationStatus.notVerified:
        return 'Не верифіковано';
      case VerificationStatus.pending:
        return 'На перевірці';
      case VerificationStatus.verified:
        return 'Верифіковано';
    }
  }

  // Метод для отримання відповідного кольору статусу
  Color toColor() {
    switch (this) {
      case VerificationStatus.notVerified:
        return Colors.red;
      case VerificationStatus.pending:
        return Colors.orange;
      case VerificationStatus.verified:
        return Colors.green;
    }
  }
}

class UserModel {
  final int? id;
  final String email;
  final String? lastLogin;
  final bool? isSuperuser;
  final bool? isActive;
  final bool? isStaff;
  final String? createdAt;
  final String? updatedAt;
  final ProfileModel? profile;

  UserModel({
    this.id,
    required this.email,
    this.lastLogin,
    this.isSuperuser,
    this.isActive,
    this.isStaff,
    this.createdAt,
    this.updatedAt,
    this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    return UserModel(
      id: json['id'],
      email: json['email'],
      lastLogin: json['last_login'],
      isSuperuser: json['is_superuser'],
      isActive: json['is_active'],
      isStaff: json['is_staff'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      profile: profile != null && profile is Map<String, dynamic>
          ? ProfileModel.fromJson(profile)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'email': email,
    };
    
    // Додаємо поля тільки якщо вони не null
    if (id != null) json['id'] = id;
    if (lastLogin != null) json['last_login'] = lastLogin;
    if (isSuperuser != null) json['is_superuser'] = isSuperuser;
    if (isActive != null) json['is_active'] = isActive;
    if (isStaff != null) json['is_staff'] = isStaff;
    if (createdAt != null) json['created_at'] = createdAt;
    if (updatedAt != null) json['updated_at'] = updatedAt;
    
    // Профіль також перевіряємо окремо
    if (profile != null) {
      final pJson = profile!.toJson();
      if (pJson.isNotEmpty) json['profile'] = pJson;
    }
    
    return json;
  }
}

class ProfileModel {
  final int? id;
  final String name;
  final String surname;
  final String? avatar;
  final VerificationStatus verificationStatus;

  ProfileModel({
    this.id,
    required this.name,
    required this.surname,
    this.avatar,
    this.verificationStatus = VerificationStatus.notVerified,
  });

  // Допоміжний геттер для зворотної сумісності
  bool get isVerified => verificationStatus == VerificationStatus.verified;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Обробка різних форматів даних від API
    var verificationValue = json['verification_status'] ?? json['is_verified'];
    
    // Для нових користувачів з API може прийти null, тоді встановлюємо notVerified
    if (verificationValue == null) {
      return ProfileModel(
        id: json['id'],
        name: json['name'],
        surname: json['surname'],
        avatar: json['avatar'],
        verificationStatus: VerificationStatus.notVerified,
      );
    }
    
    // Якщо це булеве значення
    if (verificationValue is bool) {
      return ProfileModel(
        id: json['id'],
        name: json['name'],
        surname: json['surname'],
        avatar: json['avatar'],
        verificationStatus: verificationValue 
            ? VerificationStatus.verified 
            : VerificationStatus.notVerified,
      );
    }
    
    // Якщо це рядок статусу
    return ProfileModel(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      avatar: json['avatar'],
      verificationStatus: VerificationStatusExtension.fromJson(verificationValue as String?),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'surname': surname,
      'verification_status': verificationStatus.toJson(),
      'is_verified': isVerified, // Для зворотної сумісності
    };
    
    // Додаємо null-able поля тільки якщо вони не null
    if (id != null) json['id'] = id;
    if (avatar != null) json['avatar'] = avatar;
    
    return json;
  }

  ProfileModel copyWith({
    int? id,
    String? name,
    String? surname,
    String? avatar,
    VerificationStatus? verificationStatus,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      avatar: avatar ?? this.avatar,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final ProfileModel profile;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.profile,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'profile': profile.toJson(),
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class TokenResponse {
  final String refresh;
  final String access;

  TokenResponse({
    required this.refresh,
    required this.access,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      refresh: json['refresh'],
      access: json['access'] ?? '',
    );
  }
}
