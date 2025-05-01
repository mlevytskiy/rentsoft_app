class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String avatarUrl;
  final bool isVerified;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.avatarUrl,
    required this.isVerified,
  });

  User copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? avatarUrl,
  }) {
    return User(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified,
    );
  }
}
