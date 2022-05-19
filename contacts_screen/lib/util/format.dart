class FormatPlus {
  /// Formats a string of integers into a readable phone number format.
  ///
  /// Example:
  /// ```dart
  /// var phoneNumber1 = '12345678912';
  /// var phoneNumber2 = '1234567891';
  /// var phoneNumber3 = '1234567';
  ///
  /// print(formatPhoneNumber(phoneNumber1)); // +1 (234) 567-8912
  /// print(formatPhoneNumber(phoneNumber2)); // (123) 456-7891
  /// print(formatPhoneNumber(phoneNumber3)); // 123-4567
  ///
  /// ```
  static String formatPhoneNumber(String phoneNumber) {
    String formattedPhoneNumber = "";
    if (phoneNumber.length == 11) {
      formattedPhoneNumber =
          // ignore: prefer_adjacent_string_concatenation
          "\n+${phoneNumber.substring(0, 1)} (${phoneNumber.substring(1, 4)}) " +
              "${phoneNumber.substring(4, 7)}-${phoneNumber.substring(7, phoneNumber.length)}";
    } else if (phoneNumber.length >= 10) {
      // ignore: prefer_adjacent_string_concatenation
      formattedPhoneNumber = "\n(${phoneNumber.substring(0, 3)}) " +
          "${phoneNumber.substring(3, 6)}-${phoneNumber.substring(6, phoneNumber.length)}";
    } else {
      formattedPhoneNumber =
          "${phoneNumber.substring(0, 3)}-${phoneNumber.substring(3, phoneNumber.length)}";
    }
    return formattedPhoneNumber;
  }
}
