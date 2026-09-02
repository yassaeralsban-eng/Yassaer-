import '../../domain/entities/user.dart';

/// Data model for the users collection in Firestore (SAD section 10).
class UserModel {
  const UserModel({
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

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
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

  User toEntity() => User(
    id: id,
    displayName: displayName,
    phone: phone,
    photoUrl: photoUrl,
    role: role,
    trustScore: trustScore,
    status: status,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory UserModel.fromEntity(User entity) => UserModel(
    id: entity.id,
    displayName: entity.displayName,
    phone: entity.phone,
    photoUrl: entity.photoUrl,
    role: entity.role,
    trustScore: entity.trustScore,
    status: entity.status,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );
}
