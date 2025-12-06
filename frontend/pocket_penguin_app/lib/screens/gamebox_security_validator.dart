/*
  Security validation module for GameBox penguin dressing mechanics
  Implements CWE-20: Improper Input Validation mitigations

  CWE-20 is a common weakness where applications fail to validate or
  sanitize user inputs, leading to security vulnerabilities such as:
  - Path traversal attacks (e.g., "../../../etc/passwd")
  - Injection attacks (e.g., XSS, command injection)
  - Denial of service (e.g., oversized inputs)
  - Logic bypass (e.g., invalid state values)
*/

class GameBoxSecurityValidator {
  // Whitelist of allowed clothing item names (safe values)
  static const Set<String> _allowedHats = {
    'none',
    'pockp_bumpy_helm',
    'pockp_coco_hat',
    'pockp_eyebrows_orange',
    'pockp_headbow_pink',
    'pockp_straw_hat',
  };

  static const Set<String> _allowedClothes = {
    'none',
    'pockp_bib_red',
    'pockp_bowtie_red',
    'pockp_shirt_red',
    'pockp_striped_shirt_red',
  };

  static const Set<String> _allowedShoes = {
    'none',
    'pockp_drip_purple_gold',
    'pockp_drip_red',
  };

  static const Set<String> _allowedBackgrounds = {
    '', // empty string is valid (no background)
    'pockp_cloud_land_theme',
    'pockp_day_sky_bground',
  };

  /// Maximum allowed length for any clothing item name (prevent buffer overflow)
  static const int _maxItemNameLength = 100;

  /// CWE-20 Mitigation: Validate hat input using whitelist approach
  ///
  /// Validates:
  /// - Null/empty check (except special cases)
  /// - Length validation (prevents DOS via oversized input)
  /// - Whitelist validation (only allow known safe values)
  /// - Path traversal prevention (no "../" sequences)
  ///
  /// Returns validated hat name or 'none' if invalid
  static String validateHat(String? input) {
    // Reject null input
    if (input == null) return 'none';

    // Length validation - prevent DOS attacks
    if (input.length > _maxItemNameLength) {
      throw ValidationException(
        'Hat name exceeds maximum length of $_maxItemNameLength characters',
        input,
      );
    }

    // Path traversal attack prevention
    if (input.contains('..') || input.contains('/') || input.contains('\\')) {
      throw ValidationException(
        'Hat name contains invalid path traversal characters',
        input,
      );
    }

    // Whitelist validation - only allow known safe values
    if (!_allowedHats.contains(input)) {
      throw ValidationException(
        'Hat name "$input" is not in the allowed whitelist',
        input,
      );
    }

    return input;
  }

  /// CWE-20 Mitigation: Validate clothes input using whitelist approach
  static String validateClothes(String? input) {
    if (input == null) return 'none';

    if (input.length > _maxItemNameLength) {
      throw ValidationException(
        'Clothes name exceeds maximum length of $_maxItemNameLength characters',
        input,
      );
    }

    if (input.contains('..') || input.contains('/') || input.contains('\\')) {
      throw ValidationException(
        'Clothes name contains invalid path traversal characters',
        input,
      );
    }

    if (!_allowedClothes.contains(input)) {
      throw ValidationException(
        'Clothes name "$input" is not in the allowed whitelist',
        input,
      );
    }

    return input;
  }

  /// CWE-20 Mitigation: Validate shoes input using whitelist approach
  static String validateShoes(String? input) {
    if (input == null) return 'none';

    if (input.length > _maxItemNameLength) {
      throw ValidationException(
        'Shoes name exceeds maximum length of $_maxItemNameLength characters',
        input,
      );
    }

    if (input.contains('..') || input.contains('/') || input.contains('\\')) {
      throw ValidationException(
        'Shoes name contains invalid path traversal characters',
        input,
      );
    }

    if (!_allowedShoes.contains(input)) {
      throw ValidationException(
        'Shoes name "$input" is not in the allowed whitelist',
        input,
      );
    }

    return input;
  }

  /// CWE-20 Mitigation: Validate background input using whitelist approach
  /// Empty string is valid (means "no background selected")
  static String validateBackground(String? input) {
    if (input == null) return '';

    if (input.length > _maxItemNameLength) {
      throw ValidationException(
        'Background name exceeds maximum length of $_maxItemNameLength characters',
        input,
      );
    }

    if (input.isNotEmpty &&
        (input.contains('..') || input.contains('/') || input.contains('\\'))) {
      throw ValidationException(
        'Background name contains invalid path traversal characters',
        input,
      );
    }

    if (!_allowedBackgrounds.contains(input)) {
      throw ValidationException(
        'Background name "$input" is not in the allowed whitelist',
        input,
      );
    }

    return input;
  }
}

/// Custom exception for input validation failures (CWE-20)
class ValidationException implements Exception {
  final String message;
  final String invalidInput;

  ValidationException(this.message, this.invalidInput);

  @override
  String toString() => 'ValidationException: $message (input: "$invalidInput")';
}
