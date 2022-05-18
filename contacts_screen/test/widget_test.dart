import 'package:flutter_test/flutter_test.dart';
import 'package:my_contacts/util/format/format.dart';

void main() {
  group("Phone Number Format Tests", () {
    test('1. Format Phone Number.', () {
      var phoneNumber = '12345678912';
      String formattedNumber = FormatPlus.formatPhoneNumber(phoneNumber);
      expect(formattedNumber, '\n''+1 (234) 567-8912');
    });

    test('2. Format Phone Number.', () {
      var phoneNumber = '1234567891';
      String formattedNumber = FormatPlus.formatPhoneNumber(phoneNumber);
      expect(formattedNumber, '\n''(123) 456-7891');
    });

    test('3. Format Phone Number.', () {
      var phoneNumber = '1234567';
      String formattedNumber = FormatPlus.formatPhoneNumber(phoneNumber);
      expect(formattedNumber, '123-4567');
    });

    test('4. Format Phone Number.', () {
      var phoneNumber = '12345678';
      String formattedNumber = FormatPlus.formatPhoneNumber(phoneNumber);
      expect(formattedNumber, '123-45678');
    });
  });
}
