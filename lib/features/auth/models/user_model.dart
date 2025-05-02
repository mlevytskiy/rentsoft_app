class UserModel {
  final int? id;
  final String email;
  final String? lastLogin;
  final bool? isSuperuser;
  final bool? isActive;
  final bool? isStaff;
  final String? createdAt;
  final String? updatedAt;
  final ProfileModel profile;

  UserModel({
    this.id,
    required this.email,
    this.lastLogin,
    this.isSuperuser,
    this.isActive,
    this.isStaff,
    this.createdAt,
    this.updatedAt,
    required this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      lastLogin: json['last_login'],
      isSuperuser: json['is_superuser'],
      isActive: json['is_active'],
      isStaff: json['is_staff'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      profile: ProfileModel.fromJson(json['profile']),
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
    final profileJson = profile.toJson();
    if (profileJson.isNotEmpty) json['profile'] = profileJson;
    
    return json;
  }
}

class ProfileModel {
  final int? id;
  final String name;
  final String surname;
  final String? avatar;
  final bool isVerified;

  ProfileModel({
    this.id,
    required this.name,
    required this.surname,
    this.avatar,
    this.isVerified = false,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      avatar: json['avatar'],
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'surname': surname,
      'is_verified': isVerified,
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
    bool? isVerified,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified ?? this.isVerified,
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
