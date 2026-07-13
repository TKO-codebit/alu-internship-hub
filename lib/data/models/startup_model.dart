import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

class StartupModel extends Equatable {
  const StartupModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.sector,
    required this.campus,
    required this.teamSize,
    required this.verificationStatus,
    required this.createdAt,
    this.verifiedAt,
    this.logoUrl,
    this.rejectionReason,
  });

  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String sector;
  final String campus;
  final int teamSize;
  final VerificationStatus verificationStatus;
  final DateTime? verifiedAt;
  final String? logoUrl;
  final String? rejectionReason;
  final DateTime createdAt;

  bool get isVerified => verificationStatus == VerificationStatus.approved;

  factory StartupModel.fromMap(String id, Map<String, dynamic> map) {
    return StartupModel(
      id: id,
      ownerId: map['ownerId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      sector: map['sector'] as String? ?? AppConstants.startupSectors.first,
      campus: map['campus'] as String? ?? AppConstants.aluCampuses.first,
      teamSize: map['teamSize'] as int? ?? 1,
      verificationStatus: VerificationStatusX.fromString(
        map['verificationStatus'] as String? ?? 'pending',
      ),
      verifiedAt: (map['verifiedAt'] as Timestamp?)?.toDate(),
      logoUrl: map['logoUrl'] as String?,
      rejectionReason: map['rejectionReason'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'sector': sector,
      'campus': campus,
      'teamSize': teamSize,
      'verificationStatus': verificationStatus.value,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'logoUrl': logoUrl,
      'rejectionReason': rejectionReason,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  StartupModel copyWith({
    VerificationStatus? verificationStatus,
    DateTime? verifiedAt,
    String? rejectionReason,
  }) {
    return StartupModel(
      id: id,
      ownerId: ownerId,
      name: name,
      description: description,
      sector: sector,
      campus: campus,
      teamSize: teamSize,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      logoUrl: logoUrl,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, ownerId, name, verificationStatus];
}
