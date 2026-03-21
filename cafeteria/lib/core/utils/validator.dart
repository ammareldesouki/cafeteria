class Validator {
  static String? validateEmail(String? val) {
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$",
    );
    if (val == null || val.trim().isEmpty) {
      return 'This field is required';
    } else if (!emailRegex.hasMatch(val.trim())) {
      return 'Enter a valid email';
    } else {
      return null;
    }
  }

  // ✅ NEW: Confirm Email
  static String? validateConfirmEmail(String? val, String? email) {
    if (val == null || val.trim().isEmpty) {
      return 'This field is required';
    } else if (val.trim() != email?.trim()) {
      return 'Emails do not match';
    } else {
      return null;
    }
  }

  static String? validatePassword(String? val) {
    if (val == null || val.isEmpty) {
      return 'This field is required';
    } else if (val.length < 8) {
      return 'Password must be at least 8 characters';
    } else if (!RegExp(r'[A-Z]').hasMatch(val)) {
      return 'Password must contain at least one capital letter';
    } else if (!RegExp(r'[0-9]').hasMatch(val)) {
      return 'Password must contain at least one number';
    } else if (!RegExp(r'[@$!#%^&*?]').hasMatch(val)) {
      return 'Password must contain at least one special character (@, \$, !, #, %, ^, &, *, ?)';
    } else {
      return null;
    }
  }

  static String? validateConfirmPassword(String? val, String? password) {
    if (val == null || val.isEmpty) {
      return 'This field is required';
    } else if (val != password) {
      return 'Passwords do not match'; // ✅ Fixed misleading message
    } else {
      return null;
    }
  }

  static String? validateUsername(String? val) {
    final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9,.-]+$');
    if (val == null || val.isEmpty) {
      return 'This field is required';
    } else if (!usernameRegex.hasMatch(val)) {
      return 'Enter a valid username';
    } else {
      return null;
    }
  }

  static String? validateFullName(String? val) {
    if (val == null || val.isEmpty) {
      return 'This field is required';
    } else {
      return null;
    }
  }

  static String? validatePhoneNumber(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'This field is required';
    }

    final String phone = val.trim();

    final RegExp canadaRegex = RegExp(r'^\+1[2-9][0-9]{9}$');
    final RegExp ukRegex = RegExp(r'^\+44[1-9][0-9]{9}$');

    if (!canadaRegex.hasMatch(phone) && !ukRegex.hasMatch(phone)) {
      return 'Enter a valid Canadian (+1XXXXXXXXXX) or UK (+44XXXXXXXXXX) phone number';
    }

    return null;
  }

  static String? validateCanadianPostalCode(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'This field is required';
    }

    final String postal = val.trim().toUpperCase();

    // Matches: A1A 1A1 or A1A1A1 (with or without space)
    final RegExp postalRegex = RegExp(
      r'^[ABCEGHJ-NPRSTVXY][0-9][ABCEGHJ-NPRSTVWXYZ]\s?[0-9][ABCEGHJ-NPRSTVWXYZ][0-9]$',
    );

    if (!postalRegex.hasMatch(postal)) {
      return 'Enter a valid Canadian postal code (e.g. A1A 1A1)';
    }

    return null;
  }
}