class FormatPlus {
  /// Formats a normalized phone number into a readable string.
  /// 
  /// If the number is not normalized, [phoneNumber] is returned.
  ///
  /// Note: This removes the country code.
  ///
  /// ```dart
  /// var phoneNumber = '+12345678912';
  /// print(formatNormalizedPhoneNumber(phoneNumber)); // (234) 567-8912
  /// 
  /// var phoneNumber = '1234567891';
  /// print(formatNormalizedPhoneNumber(phoneNumber)); // 1234567891
  /// ```
  static String formatNormalizedPhoneNumber(
      {required String phoneNumber, required bool isPhoneNormalized}) {
    if (isPhoneNormalized) {
      return "(${phoneNumber.substring(2, 5)}) "
          "${phoneNumber.substring(5, 8)}"
          "-${phoneNumber.substring(8, phoneNumber.length)}";
    }
    return phoneNumber;
  }
}
