class ValidationHelper {
  // Validation for username field
  static String? validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please fill the field';
    }
    return null;
  }

  // Validation for email field
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Validation for password field
static String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a password';
  }
  if (value.length < 6) {
    return 'Must be at least 6 characters long';
  }
  if (!RegExp(r'(?=.*[A-Za-z])').hasMatch(value)) {
    return 'Must include at least one letter';
  }
  if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
    return 'Must include at least one uppercase letter';
  }
  if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
    return 'Must include at least one number';
  }
  if (!RegExp(r'(?=.*[!\\$@%])').hasMatch(value)) {
    return 'Must include at least one special character (!\$@%)';
  }
  return null;
}

  // Validation for confirming password match
  static String? validateConfirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Validation to check if new password is different from current password
  static String? validateNewPassword(String? newPassword, String? currentPassword) {
    if (newPassword == null || newPassword.isEmpty) {
      return 'Please enter a new password';
    }
    if (newPassword == currentPassword) {
      return 'New password cannot be the same as the current password';
    }
    return null;
  }
}