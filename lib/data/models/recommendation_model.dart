import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

class RecommendationModel extends Equatable {
  const RecommendationModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.facilitatorId,
    required this.facilitatorName,
    required this.purpose,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.recommendationText,
    this.linkedInUrl,
    this.githubUrl,
  });

  final String id;
  final String studentId;
  final String studentName;
  final String facilitatorId;
  final String facilitatorName;
  final String purpose;
  final String message;
  final RecommendationStatus status;
  final String? recommendationText;
  final String? linkedInUrl;
  final String? githubUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory RecommendationModel.fromMap(String id, Map<String, dynamic> map) {
    return RecommendationModel(
      id: id,
      studentId: map['studentId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? '',
      facilitatorId: map['facilitatorId'] as String? ?? '',
      facilitatorName: map['facilitatorName'] as String? ?? '',
      purpose: map['purpose'] as String? ?? '',
      message: map['message'] as String? ?? '',
      status: RecommendationStatusX.fromString(map['status'] as String? ?? 'pending'),
      recommendationText: map['recommendationText'] as String?,
      linkedInUrl: map['linkedInUrl'] as String?,
      githubUrl: map['githubUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'facilitatorId': facilitatorId,
      'facilitatorName': facilitatorName,
      'purpose': purpose,
      'message': message,
      'status': status.value,
      'recommendationText': recommendationText,
      'linkedInUrl': linkedInUrl,
      'githubUrl': githubUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  RecommendationModel copyWith({
    RecommendationStatus? status,
    String? recommendationText,
    DateTime? updatedAt,
  }) {
    return RecommendationModel(
      id: id,
      studentId: studentId,
      studentName: studentName,
      facilitatorId: facilitatorId,
      facilitatorName: facilitatorName,
      purpose: purpose,
      message: message,
      status: status ?? this.status,
      recommendationText: recommendationText ?? this.recommendationText,
      linkedInUrl: linkedInUrl,
      githubUrl: githubUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, studentId, facilitatorId, status];
}
