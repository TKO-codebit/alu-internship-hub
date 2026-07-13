enum UserRole { student, startup, admin }

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

class AppConstants {
  static const appName = 'Campus Launchpad';
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
