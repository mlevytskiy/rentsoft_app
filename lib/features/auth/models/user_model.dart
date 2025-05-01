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
    return {
      'id': id,
      'email': email,
      'last_login': lastLogin,
      'is_superuser': isSuperuser,
      'is_active': isActive,
      'is_staff': isStaff,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'profile': profile.toJson(),
    };
  }
}

class ProfileModel {
  final int? id;
  final String name;
  final String surname;
  final String? avatar;

  ProfileModel({
    this.id,
    required this.name,
    required this.surname,
    this.avatar,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'avatar': avatar,
    };
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
