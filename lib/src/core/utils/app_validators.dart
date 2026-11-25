class AppValidators {
  static String? requiredField(String? value, {String message = 'This field is required'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? positiveNumber(String? value, {String message = 'Please enter a valid price'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    final numVal = double.tryParse(value.replaceAll(',', '.'));
    if (numVal == null || numVal <= 0) {
      return message;
    }
    return null;
  }
}
