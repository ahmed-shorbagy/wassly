import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String userType;
  final DateTime createdAt;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.userType,
    required this.createdAt,
    required this.isActive,
  });

  @override
  List<Object> get props => [
    id,
    email,
    name,
    phone,
    userType,
    createdAt,
    isActive,
  ];
}
