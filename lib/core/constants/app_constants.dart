enum UserRole { student, startup, facilitator, admin }

extension UserRoleX on UserRole {
  String get value => name;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.student,
    );
  }

  String get label {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.startup:
        return 'Startup Founder';
      case UserRole.facilitator:
        return 'Facilitator';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

enum VerificationStatus { pending, approved, rejected }

extension VerificationStatusX on VerificationStatus {
  String get value => name;

  static VerificationStatus fromString(String value) {
    return VerificationStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => VerificationStatus.pending,
    );
  }
}

enum ApplicationStatus { submitted, reviewing, accepted, rejected }

extension ApplicationStatusX on ApplicationStatus {
  String get value => name;

  static ApplicationStatus fromString(String value) {
    return ApplicationStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ApplicationStatus.submitted,
    );
  }

  String get label {
    switch (this) {
      case ApplicationStatus.submitted:
        return 'Submitted';
      case ApplicationStatus.reviewing:
        return 'Under Review';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Not Selected';
    }
  }
}

enum RecommendationStatus { pending, completed, declined }

extension RecommendationStatusX on RecommendationStatus {
  String get value => name;

  static RecommendationStatus fromString(String value) {
    return RecommendationStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => RecommendationStatus.pending,
    );
  }

  String get label {
    switch (this) {
      case RecommendationStatus.pending:
        return 'Pending';
      case RecommendationStatus.completed:
        return 'Completed';
      case RecommendationStatus.declined:
        return 'Declined';
    }
  }
}

class AppConstants {
  static const appName = 'Campus Launchpad';
  static const studentDomain = 'alustudent.com';
  static const facilitatorDomain = 'alueducation.com';
  static const allowedDomains = [studentDomain, facilitatorDomain];

  static const aluCampuses = ['Kigali', 'Mauritius', 'Online'];
  static const opportunityCategories = [
    'Software Development',
    'UI/UX Design',
    'Marketing',
    'Operations',
    'Research',
    'Business Analysis',
    'Content Creation',
    'Community Management',
  ];
  static const startupSectors = [
    'EdTech',
    'FinTech',
    'HealthTech',
    'Climate Tech',
    'AgriTech',
    'Social Impact',
    'E-commerce',
    'Other',
  ];
}
