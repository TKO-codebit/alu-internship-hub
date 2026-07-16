import '../constants/app_constants.dart';

class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return aluEmail(value);
  }

  static String? aluEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final normalized = value.trim().toLowerCase();
    final domain = normalized.split('@').last;
    if (!AppConstants.allowedDomains.contains(domain)) {
      return 'Use your ALU email (@${AppConstants.studentDomain} or @${AppConstants.facilitatorDomain})';
    }
    return null;
  }

  static String? emailForRole(String? value, UserRole role) {
    final base = aluEmail(value);
    if (base != null) return base;
    final domain = value!.trim().toLowerCase().split('@').last;
    if (role == UserRole.facilitator && domain != AppConstants.facilitatorDomain) {
      return 'Facilitators must use @${AppConstants.facilitatorDomain}';
    }
    if ((role == UserRole.student || role == UserRole.startup) &&
        domain != AppConstants.studentDomain) {
      return 'Students and founders must use @${AppConstants.studentDomain}';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? requiredField(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  static String? url(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'URL is required' : null;
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme) {
      return 'Enter a valid URL (include https://)';
    }
    return null;
  }
}
