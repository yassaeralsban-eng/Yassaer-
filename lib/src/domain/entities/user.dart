/// User role in the system.
enum UserRole {
  user,
  moderator,
  admin;

  String get label => switch (this) {
    UserRole.user => 'مستخدم',
    UserRole.moderator => 'مشرف',
    UserRole.admin => 'مدير النظام',
  };

  static UserRole fromName(String? name) {
    for (final role in UserRole.values) {
      if (role.name == name) return role;
    }
    return UserRole.user;
  }
}

/// User account status.
enum UserStatus {
  active,
  suspended,
  banned;

  String get label => switch (this) {
    UserStatus.active => 'نشط',
    UserStatus.suspended => 'موقوف',
    UserStatus.banned => 'محظور',
  };

  static UserStatus fromName(String? name) {
    for (final status in UserStatus.values) {
      if (status.name == name) return status;
    }
    return UserStatus.active;
  }
}

/// Represents a user account in the system.
class User {
  const User({
    required this.id,
    required this.displayName,
    required this.phone,
    this.photoUrl,
    required this.role,
    this.trustScore = 0,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String displayName;
  final String phone;
  final String? photoUrl;
  final UserRole role;
  final int trustScore;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'] as String,
    displayName: map['displayName'] as String,
    phone: map['phone'] as String,
    photoUrl: map['photoUrl'] as String?,
    role: UserRole.fromName(map['role'] as String?),
    trustScore: (map['trustScore'] as num?)?.toInt() ?? 0,
    status: UserStatus.fromName(map['status'] as String?),
    createdAt: (map['createdAt'] as dynamic).toDate(),
    updatedAt: (map['updatedAt'] as dynamic).toDate(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'displayName': displayName,
    'phone': phone,
    'photoUrl': photoUrl,
    'role': role.name,
    'trustScore': trustScore,
    'status': status.name,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  User copyWith({
    String? displayName,
    String? phone,
    String? photoUrl,
    UserRole? role,
    int? trustScore,
    UserStatus? status,
    DateTime? updatedAt,
  }) => User(
    id: id,
    displayName: displayName ?? this.displayName,
    phone: phone ?? this.phone,
    photoUrl: photoUrl ?? this.photoUrl,
    role: role ?? this.role,
    trustScore: trustScore ?? this.trustScore,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

/// Extension to safely convert a Timestamp-like object to DateTime.
extension DateTimeX on dynamic {
  DateTime toDate() => this is DateTime ? this as DateTime : DateTime.now();
}
