import '../constants/app_constants.dart';

class AluEmailPolicy {
  static bool isAllowed(String email) {
    final domain = _domain(email);
    return AppConstants.allowedDomains.contains(domain);
  }

  static String _domain(String email) => email.trim().toLowerCase().split('@').last;

  static bool isStudentDomain(String email) => _domain(email) == AppConstants.studentDomain;

  static bool isFacilitatorDomain(String email) =>
      _domain(email) == AppConstants.facilitatorDomain;

  /// Returns the only role allowed for this domain, or null when the user chooses.
  static UserRole? lockedRoleForEmail(String email) {
    if (isFacilitatorDomain(email)) return UserRole.facilitator;
    return null;
  }

  static List<UserRole> selectableRolesForEmail(String email) {
    if (isFacilitatorDomain(email)) {
      return [UserRole.facilitator];
    }
    if (isStudentDomain(email)) {
      return [UserRole.student, UserRole.startup];
    }
    return [];
  }

  static String domainHint() =>
      '@${AppConstants.studentDomain} (students/founders) or @${AppConstants.facilitatorDomain} (facilitators)';
}
