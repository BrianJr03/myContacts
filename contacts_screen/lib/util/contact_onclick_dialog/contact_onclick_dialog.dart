import 'package:flutter/material.dart';

class ConfirmationDialog {
  /// Shows confirmation dialog to user.
  ///
  /// Best used to prevent a user from accidentally performing
  /// a significant action such as account deletion.
  ///
  /// [onSubmitTap] is executed when a user confirms their action.
  ///
  /// [onCancelTap] is executed when a user cancels their action.
  ///
  /// [submitText] is displayed as a button to confirm action. Ex: 'OK'
  ///
  /// [cancelText] is displayed as a button to cancel action. Ex: 'BACK'
  static void showConfirmationDialog({
    required BuildContext context,
    required Widget title,
    required Widget content,
    required Function() onSubmitTap,
    required Function() onCancelTap,
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
          TextButton(
            onPressed: onCancelTap,
            child:
                Text(cancelText, style: const TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: onSubmitTap,
            child: Text(submitText,
                style: const TextStyle(color: Color(0xff53a99a))),
          ),
        ],
      ),
    );
  }

  static TextSpan dialogTitleText(Map contact) {
    return TextSpan(
        text: 'How would you like to contact ',
        children: <InlineSpan>[
          TextSpan(
              text: '${contact['name']}',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff53a99a)),
              children: const [
                TextSpan(
                    text: ' ?',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black))
              ])
        ]);
  }
}
