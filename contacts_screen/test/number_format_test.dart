import 'package:my_contacts/util/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Phone Number Format Tests", () {
    test('1. Format Normalized Phone Number.', () {
      var phoneNumber = '+12345678912';
      String formattedNumber = FormatPlus.formatNormalizedPhoneNumber(
          phoneNumber: phoneNumber, isPhoneNormalized: true);
      expect(formattedNumber, '(234) 567-8912');
    });

    test('2. Format Normalized Phone Number.', () {
      var phoneNumber = '1234567891';
      String formattedNumber = FormatPlus.formatNormalizedPhoneNumber(
          phoneNumber: phoneNumber, isPhoneNormalized: false);
      expect(formattedNumber, '1234567891');
    });

    test('3. Format Normalized Phone Number.', () {
      var phoneNumber = '1234567';
      String formattedNumber = FormatPlus.formatNormalizedPhoneNumber(
          phoneNumber: phoneNumber, isPhoneNormalized: false);
      expect(formattedNumber, '1234567');
    });

    test('4. Format Normalized Phone Number.', () {
      var phoneNumber = '+34512345678';
      String formattedNumber = FormatPlus.formatNormalizedPhoneNumber(
          phoneNumber: phoneNumber, isPhoneNormalized: true);
      expect(formattedNumber, '(451) 234-5678');
    });
  });
}
