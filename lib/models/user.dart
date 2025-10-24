class User {
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? dateOfBirth;
  final String? avatar;
  final String? role;
  final bool? isActive;
  final int? currentStreak;
  final int? bestStreak;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    this.userId,
    this.firstName,
    this.lastName,
    required this.email,
    this.dateOfBirth,
    this.avatar,
    this.role,
    this.isActive,
    this.currentStreak,
    this.bestStreak,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
  });

  // Computed property for full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return email.split('@')[0]; // Use email prefix if no name
  }

  // Computed property for display name (first name or email prefix)
  String get displayName {
    return (firstName != null ? '$firstName' : '') + (lastName != null ? ' $lastName' : '');
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String,
      dateOfBirth: json['dateOfBirth'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String?,
      isActive: json['isActive'] as bool?,
      currentStreak: json['currentStreak'] as int?,
      bestStreak: json['bestStreak'] as int?,
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin'] as String) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'avatar': avatar,
      'role': role,
      'isActive': isActive,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // CopyWith method for updates
  User copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? dateOfBirth,
    String? avatar,
    String? role,
    bool? isActive,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(userId: $userId, fullName: $fullName, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.userId == userId && other.email == email;
  }

  @override
  int get hashCode => Object.hash(userId, email);
}