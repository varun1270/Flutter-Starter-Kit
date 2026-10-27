abstract final class Validators {
  static String? required(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value, label: 'Email');
    if (requiredError != null) return requiredError;
    final isValid = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(value!.trim());
    return isValid ? null : 'Enter a valid email address';
  }

  static String? password(String? value) {
    if (value == null || value.length < 8) return 'Use at least 8 characters';
    return null;
  }
}
