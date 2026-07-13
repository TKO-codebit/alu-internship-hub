import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

class OpportunityModel extends Equatable {
  const OpportunityModel({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.title,
    required this.description,
    required this.category,
    required this.skillsRequired,
    required this.locationType,
    required this.campus,
    required this.durationWeeks,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String startupId;
  final String startupName;
  final String title;
  final String description;
  final String category;
  final List<String> skillsRequired;
  final String locationType;
  final String campus;
  final int durationWeeks;
  final bool isActive;
  final DateTime createdAt;

  factory OpportunityModel.fromMap(String id, Map<String, dynamic> map) {
    return OpportunityModel(
      id: id,
      startupId: map['startupId'] as String? ?? '',
      startupName: map['startupName'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? AppConstants.opportunityCategories.first,
      skillsRequired: List<String>.from(map['skillsRequired'] as List<dynamic>? ?? []),
      locationType: map['locationType'] as String? ?? 'on-campus',
      campus: map['campus'] as String? ?? AppConstants.aluCampuses.first,
      durationWeeks: map['durationWeeks'] as int? ?? 8,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startupId': startupId,
      'startupName': startupName,
      'title': title,
      'description': description,
      'category': category,
      'skillsRequired': skillsRequired,
      'locationType': locationType,
      'campus': campus,
      'durationWeeks': durationWeeks,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [id, startupId, title, isActive, createdAt];
}
