import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.emailVerified,
    required super.role,
    required super.createdAt,
    required super.updatedAt,
    required super.phoneNumber,
    required super.gender,
    required super.totalOrders,
    required super.completedOrders,
    required super.balance,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? (map['userId'] ?? ''),
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      emailVerified: map['emailVerified'] ?? false,
      role: map['role'] ?? 'user',
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      gender: map['gender'] ?? '',
      totalOrders: map['totalOrders'] ?? 0,
      completedOrders: map['completedOrders'] ?? 0,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'emailVerified': emailVerified,
        'role': role,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'totalOrders': totalOrders,
        'completedOrders': completedOrders,
        'balance': balance,
      };
}
