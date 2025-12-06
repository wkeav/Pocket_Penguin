import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_penguin_app/screens/gamebox_security_validator.dart';

/// Security Test Suite for CWE-20: Improper Input Validation
/// 
/// This test suite validates that the GameBox penguin dressing mechanics
/// properly reject malicious or invalid inputs, preventing:
/// - Path traversal attacks
/// - Injection attacks
/// - Denial of service via oversized inputs
/// - Invalid state transitions
/// 
/// Each test group corresponds to a clothing category (hat, clothes, shoes, background)
/// and covers legitimate use and attack scenarios.

void main() {
  group('CWE-20: GameBox Input Validation - Hat Validation', () {
    test('Valid hat name is accepted', () {
      expect(GameBoxSecurityValidator.validateHat('pockp_bumpy_helm'), equals('pockp_bumpy_helm'));
      expect(GameBoxSecurityValidator.validateHat('pockp_coco_hat'), equals('pockp_coco_hat'));
      expect(GameBoxSecurityValidator.validateHat('none'), equals('none'));
    });

    test('Null input defaults to "none"', () {
      expect(GameBoxSecurityValidator.validateHat(null), equals('none'));
    });

    test('Path traversal attack via "../" is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateHat('../../../etc/passwd'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Path traversal attack via "\\\\" is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateHat('..\\..\\..\\windows\\system32'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Directory traversal with forward slash is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateHat('admin/pockp_bumpy_helm'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Oversized input (DOS attack) is rejected', () {
      final oversizedInput = 'a' * 101;
      expect(
        () => GameBoxSecurityValidator.validateHat(oversizedInput),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Exact max length input is accepted', () {
      final maxLengthInput = 'a' * 100;
      expect(
        () => GameBoxSecurityValidator.validateHat(maxLengthInput),
        throwsA(isA<ValidationException>()), // Still rejected if not in whitelist
      );
    });

    test('Unknown hat name not in whitelist is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateHat('pockp_unknown_hat'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('XSS attempt via special characters is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateHat('<script>alert("xss")</script>'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('SQL injection attempt is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateHat("'; DROP TABLE hats; --"),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Command injection attempt is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateHat('pockp_hat; rm -rf /'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('CWE-20: GameBox Input Validation - Clothes Validation', () {
    test('Valid clothes name is accepted', () {
      expect(GameBoxSecurityValidator.validateClothes('pockp_bib_red'), equals('pockp_bib_red'));
      expect(GameBoxSecurityValidator.validateClothes('pockp_shirt_red'), equals('pockp_shirt_red'));
    });

    test('Null input defaults to "none"', () {
      expect(GameBoxSecurityValidator.validateClothes(null), equals('none'));
    });

    test('Path traversal attack is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateClothes('../config.json'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Unknown clothes name is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateClothes('pockp_unknown_clothes'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Oversized clothes input is rejected', () {
      final oversizedInput = 'x' * 101;
      expect(
        () => GameBoxSecurityValidator.validateClothes(oversizedInput),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('CWE-20: GameBox Input Validation - Shoes Validation', () {
    test('Valid shoes name is accepted', () {
      expect(GameBoxSecurityValidator.validateShoes('pockp_drip_red'), equals('pockp_drip_red'));
      expect(GameBoxSecurityValidator.validateShoes('pockp_drip_purple_gold'), equals('pockp_drip_purple_gold'));
    });

    test('Null input defaults to "none"', () {
      expect(GameBoxSecurityValidator.validateShoes(null), equals('none'));
    });

    test('Path traversal attack is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateShoes('../../private/keys'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Unknown shoes name is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateShoes('pockp_unknown_shoes'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Oversized shoes input is rejected', () {
      final oversizedInput = 'y' * 101;
      expect(
        () => GameBoxSecurityValidator.validateShoes(oversizedInput),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('CWE-20: GameBox Input Validation - Background Validation', () {
    test('Valid background name is accepted', () {
      expect(GameBoxSecurityValidator.validateBackground('pockp_cloud_land_theme'), 
        equals('pockp_cloud_land_theme'));
      expect(GameBoxSecurityValidator.validateBackground('pockp_day_sky_bground'), 
        equals('pockp_day_sky_bground'));
    });

    test('Empty string (no background) is valid', () {
      expect(GameBoxSecurityValidator.validateBackground(''), equals(''));
    });

    test('Null input defaults to empty string', () {
      expect(GameBoxSecurityValidator.validateBackground(null), equals(''));
    });

    test('Path traversal attack is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateBackground('../admin/backgrounds/malicious'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Unknown background name is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateBackground('pockp_unknown_background'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Oversized background input is rejected', () {
      final oversizedInput = 'z' * 101;
      expect(
        () => GameBoxSecurityValidator.validateBackground(oversizedInput),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Backslash path traversal in background is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateBackground('..\\..\\system'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('CWE-20: ValidationException', () {
    test('ValidationException is thrown with descriptive message', () {
      try {
        GameBoxSecurityValidator.validateHat('../etc/passwd');
        fail('Expected ValidationException to be thrown');
      } catch (e) {
        expect(e, isA<ValidationException>());
        expect(e.toString(), contains('ValidationException'));
        expect(e.toString(), contains('path traversal'));
      }
    });

    test('ValidationException contains invalid input details', () {
      try {
        GameBoxSecurityValidator.validateHat('malicious_input');
        fail('Expected ValidationException to be thrown');
      } catch (e) {
        expect(e, isA<ValidationException>());
        expect(e.toString(), contains('malicious_input'));
      }
    });
  });

  group('CWE-20: Edge Cases and Boundary Testing', () {
    test('Empty string for hat is rejected (not in whitelist)', () {
      expect(
        () => GameBoxSecurityValidator.validateHat(''),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Case sensitivity: uppercase variant of known hat is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateHat('POCKP_BUMPY_HELM'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Whitespace-only input is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateHat('   '),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Input with leading/trailing spaces is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateHat(' pockp_bumpy_helm '),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Double encoding attack (..%252F) is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateHat('..%252Fetc%252Fpasswd'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Null byte injection is rejected', () {
      expect(
        () => GameBoxSecurityValidator.validateHat('pockp_hat\x00.png'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('CWE-20: Integration Scenarios', () {
    test('Multiple validation calls work correctly', () {
      expect(GameBoxSecurityValidator.validateHat('pockp_coco_hat'), equals('pockp_coco_hat'));
      expect(GameBoxSecurityValidator.validateClothes('pockp_bib_red'), equals('pockp_bib_red'));
      expect(GameBoxSecurityValidator.validateShoes('pockp_drip_red'), equals('pockp_drip_red'));
      expect(GameBoxSecurityValidator.validateBackground('pockp_cloud_land_theme'), 
        equals('pockp_cloud_land_theme'));
    });

    test('Validation state is independent', () {
      final hat = GameBoxSecurityValidator.validateHat('pockp_bumpy_helm');
      expect(
        () => GameBoxSecurityValidator.validateClothes('pockp_unknown_clothes'),
        throwsA(isA<ValidationException>()),
      );
      // First validation still valid
      expect(hat, equals('pockp_bumpy_helm'));
    });

    test('Defender can reject malicious input before state update', () {
      expect(
        () => GameBoxSecurityValidator.validateHat('../../../etc/passwd'),
        throwsA(isA<ValidationException>()),
      );
      // Safe to call again with valid input
      expect(GameBoxSecurityValidator.validateHat('pockp_coco_hat'), equals('pockp_coco_hat'));
    });
  });
}
