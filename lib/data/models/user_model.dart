import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.campus,
    required this.createdAt,
    this.skills = const [],
    this.bio,
    this.linkedInUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.photoUrl,
    this.authProvider = 'email',
  });

  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String campus;
  final List<String> skills;
  final String? bio;
  final String? linkedInUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  final String? photoUrl;
  final String authProvider;
  final DateTime createdAt;

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      email: map['email'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      role: UserRoleX.fromString(map['role'] as String? ?? 'student'),
      campus: map['campus'] as String? ?? AppConstants.aluCampuses.first,
      skills: List<String>.from(map['skills'] as List<dynamic>? ?? []),
      bio: map['bio'] as String?,
      linkedInUrl: map['linkedInUrl'] as String?,
      githubUrl: map['githubUrl'] as String?,
      portfolioUrl: map['portfolioUrl'] as String?,
      photoUrl: map['photoUrl'] as String?,
      authProvider: map['authProvider'] as String? ?? 'email',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role.value,
      'campus': campus,
      'skills': skills,
      'bio': bio,
      'linkedInUrl': linkedInUrl,
      'githubUrl': githubUrl,
      'portfolioUrl': portfolioUrl,
      'photoUrl': photoUrl,
      'authProvider': authProvider,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? fullName,
    UserRole? role,
    String? campus,
    List<String>? skills,
    String? bio,
    String? linkedInUrl,
    String? githubUrl,
    String? portfolioUrl,
    String? photoUrl,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      campus: campus ?? this.campus,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      photoUrl: photoUrl ?? this.photoUrl,
      authProvider: authProvider,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, fullName, role, campus, skills];
}
