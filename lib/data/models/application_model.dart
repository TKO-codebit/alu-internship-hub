import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

class ApplicationModel extends Equatable {
  const ApplicationModel({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.studentId,
    required this.studentName,
    required this.startupId,
    required this.startupName,
    required this.coverLetter,
    required this.status,
    required this.appliedAt,
    required this.updatedAt,
  });

  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String studentId;
  final String studentName;
  final String startupId;
  final String startupName;
  final String coverLetter;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime updatedAt;

  factory ApplicationModel.fromMap(String id, Map<String, dynamic> map) {
    return ApplicationModel(
      id: id,
      opportunityId: map['opportunityId'] as String? ?? '',
      opportunityTitle: map['opportunityTitle'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? '',
      startupId: map['startupId'] as String? ?? '',
      startupName: map['startupName'] as String? ?? '',
      coverLetter: map['coverLetter'] as String? ?? '',
      status: ApplicationStatusX.fromString(map['status'] as String? ?? 'submitted'),
      appliedAt: (map['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'studentId': studentId,
      'studentName': studentName,
      'startupId': startupId,
      'startupName': startupName,
      'coverLetter': coverLetter,
      'status': status.value,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ApplicationModel copyWith({ApplicationStatus? status, DateTime? updatedAt}) {
    return ApplicationModel(
      id: id,
      opportunityId: opportunityId,
      opportunityTitle: opportunityTitle,
      studentId: studentId,
      studentName: studentName,
      startupId: startupId,
      startupName: startupName,
      coverLetter: coverLetter,
      status: status ?? this.status,
      appliedAt: appliedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, opportunityId, studentId, status];
}

class AppNotificationModel extends Equatable {
  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.relatedId,
  });

  final String id;
  final String title;
  final String body;
  final bool isRead;
  final String? relatedId;
  final DateTime createdAt;

  factory AppNotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return AppNotificationModel(
      id: id,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      isRead: map['isRead'] as bool? ?? false,
      relatedId: map['relatedId'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'isRead': isRead,
      'relatedId': relatedId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [id, title, isRead];
}
