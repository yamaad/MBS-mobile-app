class Validator {
  String? validatePassword(String? value) {
    if (value!.length < 12) {
      return "password must more than be 12 charters ";
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return "password must contian at least one upper case";
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return "password must contian at least one lower case";
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return "password must contian at least a number";
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return "Password must contain one special character.";
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }
}
