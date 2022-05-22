import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:my_contacts/util/format.dart';

import '../theme/colors_plus.dart';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class DialogPlus {
  /// Shows confirmation dialog to user.
  ///
  /// Best used to prevent a user from accidentally performing
  /// a significant action such as account deletion.
  ///
  /// [onSubmitTap] is executed when a user confirms their action.
  /// The dialog is closed before any other code is executed.
  /// If null, a button will not be present.
  ///
  /// [onCancelTap] is executed when a user cancels their action.
  /// The dialog is closed before any other code is executed.
  /// If null, a button will not be present.
  ///
  /// [submitText] is displayed as a button to confirm action. Ex: 'OK'
  ///
  /// [cancelText] is displayed as a button to cancel action. Ex: 'BACK'
  static void showDialogPlus({
    required BuildContext context,
    required Widget title,
    required Widget content,
    required Function()? onSubmitTap,
    required Function()? onCancelTap,
    required String submitText,
    required String cancelText,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: title,
        content: SingleChildScrollView(
            scrollDirection: Axis.vertical, child: content),
        actions: <Widget>[
          if (onCancelTap != null)
            TextButton(
              onPressed: () {
                // Clears dialog
                Navigator.pop(context);
                onCancelTap();
              },
              child:
                  Text(cancelText, style: const TextStyle(color: Colors.black)),
            ),
          if (onSubmitTap != null)
            TextButton(
              onPressed: () {
                // Clears dialog
                Navigator.pop(context);
                onSubmitTap();
              },
              child: Text(submitText,
                  style: TextStyle(color: ColorsPlus.secondaryColor)),
            ),
        ],
      ),
    );
  }

  /// Returns a [TextField] to be used within a dialog box.
  static TextField dialogTextField(
      {bool enabled = true,
      TextInputType kbType = TextInputType.text,
      String hintText = 'Enter value here',
      TextEditingController? contr,
      Function(String)? onSubmitted}) {
    return TextField(
        maxLength: 17,
        maxLines: 1,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        onSubmitted: onSubmitted ?? (s) {},
        enabled: enabled,
        cursorColor: ColorsPlus.secondaryColor,
        style: const TextStyle().copyWith(
          fontFamily: 'Open Sans',
          color: Colors.black,
          fontWeight: FontWeight.normal,
          fontSize: 18,
        ),
        textAlign: TextAlign.start,
        keyboardType: kbType,
        controller: contr,
        decoration: InputDecoration(
            hintText: hintText,
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
                width: 1,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.0),
                topRight: Radius.circular(4.0),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 1,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.0),
                  topRight: Radius.circular(4.0),
                ))));
  }

  /// This is used as the title of the dialog that appears when a user taps a
  /// contacts's card.
  static TextSpan contactDialogTitle(Contact contact) {
    String num;
    bool isPhoneNormalized = false;
    if (contact.phones[0].normalizedNumber.toString().isNotEmpty) {
      num = contact.phones[0].normalizedNumber.toString();
      isPhoneNormalized = true;
    } else {
      num = contact.phones[0].number.toString();
    }
    return TextSpan(text: 'Contact\n', children: <InlineSpan>[
      TextSpan(
          text: "Name: ${contact.name.first} ${contact.name.last}",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorsPlus.secondaryColor),
          children: [
            TextSpan(
                text: '\nPhone: '
                    '${FormatPlus.formatNormalizedPhoneNumber(phoneNumber: num, isPhoneNormalized: isPhoneNormalized)}'
                    '\nEmail: ${contact.emails.isNotEmpty ? contact.emails[0].address : "N/A"}')
          ])
    ]);
  }
}
